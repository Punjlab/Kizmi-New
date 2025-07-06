//
//  DialogsViewController.swift
//  Tifeal
//
//  Created by Technorizen on 12/13/17.
//  Copyright © 2017 Technorizen. All rights reserved.
//

import UIKit
class DialogTableViewCellModel: NSObject {
    
    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var blobId : NSInteger = 0
    
    
    init(dialog: QBChatDialog) {
        super.init()
        
        switch (dialog.type){
        case .publicGroup:
            self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
        case .group:
            self.detailTextLabelText = "SA_STR_GROUP".localized
        case .private:
            self.detailTextLabelText = "SA_STR_PRIVATE".localized
            
            if dialog.recipientID == -1 {
                return
            }
            
            // Getting recipient from users service.
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
                print(recipient)
                self.textLabelText = recipient.fullName ?? recipient.email!
                
                // Dialog icon
                self.blobId = recipient.blobID
                
            }
        }
        
        if self.textLabelText.isEmpty {
            // group chat
            
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }
        
        // Unread messages counter label
        
        if (dialog.unreadMessagesCount > 0) {
            
            var trimmedUnreadMessageCount : String
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            
            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false
            
        }
        else {
            
            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }
        
        
    }
}

class DialogsViewController: UIViewController, QMChatServiceDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var arrNewMatches : NSArray = []
    @IBOutlet var clcVUSer: UICollectionView!
    
    private var didEnterBackgroundDate: NSDate?
    private var observer: NSObjectProtocol?
    
    @IBOutlet var tblViewDialogs: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ServicesManager.instance().chatService.addDelegate(self)
        
        ServicesManager.instance().authService.add(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        QBChat.instance.setDefaultPrivacyListWithName("public")
        self.tabBarController?.navigationItem.title = "CHAT"
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            
            if !QBChat.instance.isConnected {
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(DialogsViewController.didEnterBackgroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if (QBChat.instance.isConnected) {
            self.getDialogs()
        }
        self.GetNewMatches()
    }
    func GetNewMatches() {
        
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)match_list?user_id=\(UserDefaults.standard.value(forKey: "UserId") as! String)",controllerView: self, success: {(_ responce: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = responce as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                    // GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: GlobalConstant.MSGServerError, on: self)
                }
            }
            else{
                let status = responseDict["status"] as! Int
                if status == 1 {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.arrNewMatches = responseDict["result"] as! NSArray
                        self.clcVUSer.reloadData()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        //GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "No data found!", on: self)
                    }
                }
            }
        }, failure: {(_ error: Error?) -> Void in
            //error
            DispatchQueue.main.async {
                //GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: GlobalConstant.MSGServerError, on: self)
            }
            
        })
    }
    // MARK:- CollectionView Delegate and Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrNewMatches.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let strImage = (arrNewMatches.object(at: indexPath.row)as! NSDictionary).value(forKey: "image") as! String
        let downloadURL = NSURL(string: strImage)
        cell.bgImage.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userID = (arrNewMatches.object(at: indexPath.row)as! NSDictionary).value(forKey: "id") as! String
        self.didTappedonContact(userrID: userID)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    func didTappedonContact(userrID: String) {
        
        let completion = {[weak self] (response: QBResponse?, createdDialog: QBChatDialog?) -> Void in
            
            if createdDialog != nil {
                print(createdDialog!)
                self?.openNewDialog(dialog: createdDialog)
            }
            
            guard let unwrappedResponse = response else {
                print("Error empty response")
                return
            }
            
            if let error = unwrappedResponse.error {
                print(error.error!)
            }
            else {
                
            }
        }
        
        QBRequest.user(withExternalID: UInt(userrID)!, successBlock: { (response, user) in
            print(response)
            print(user)
            var users: [QBUUser] = []
            users.append(user)
            
            if users.count == 1 {
                let recepientuser : QBUUser = users.first!
                self.createChat(name: nil, users: users, completion: completion)
                self.updateSeenStatus(reciepentUSerId: String(describing: recepientuser.externalUserID))
            }
        }) { (response) in
            print(response)
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: "Array", andMessage: "\(response)", on: self)
        }
    }
    func createChat(name: String?, users:[QBUUser], completion: ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)?) {
        
        // Creating private chat.
        ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: users.first!, completion: { (response, chatDialog) in
            
            completion?(response, chatDialog)
        })
        
    }
    func openNewDialog(dialog: QBChatDialog!) {
        let chatVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.dialog = dialog
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    func updateSeenStatus(reciepentUSerId : String) {
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)update_seen?from_id=\(UserDefaults.standard.value(forKey: "UserId") as! String)&to_id=\(reciepentUSerId)",controllerView: self, success: {(_ responce: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = responce as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                    // GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: GlobalConstant.MSGServerError, on: self)
                }
            }
            else{
                let status = responseDict["status"] as! String
                if status == "1" {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                    }
                }
                else{
                    DispatchQueue.main.async {
                        //GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "No data found!", on: self)
                    }
                }
            }
        }, failure: {(_ error: Error?) -> Void in
            //error
            DispatchQueue.main.async {
                //GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: GlobalConstant.MSGServerError, on: self)
            }
            
        })
    }
    // MARK: - Notification handling
    
    func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTappedonHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - DataSource Action
    
    func getDialogs() {
        
//        if let lastActivityDate = ServicesManager.instance().lastActivityDate {
//            
//            ServicesManager.instance().chatService.fetchDialogsUpdated(from: lastActivityDate as Date, andPageLimit: kDialogsPageLimit, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
//                
//            }, completionBlock: { (response) -> Void in
//                
//                if (response.isSuccess) {
//                    
//                    ServicesManager.instance().lastActivityDate = NSDate()
//                }
//            })
//        }
//        else {
        
            SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOGS".localized, maskType: SVProgressHUDMaskType.clear)
            
            ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                
            }, completion: { (response: QBResponse?) -> Void in
                
                guard response != nil && response!.isSuccess else {
                    SVProgressHUD.showError(withStatus: "SA_STR_FAILED_LOAD_DIALOGS".localized)
                    return
                }
                
                SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
                ServicesManager.instance().lastActivityDate = NSDate()
            })
//        }
    }
    
    // MARK: - DataSource
    
    func dialogs() -> [QBChatDialog]? {
        
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dialogs = self.dialogs() {
            return dialogs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogcell", for: indexPath) as! DialogTableViewCell
        
        if ((self.dialogs()?.count)! < indexPath.row) {
            return cell
        }
        
        guard let chatDialog = self.dialogs()?[indexPath.row] else {
            return cell
        }
        
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.id!
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
        print(cellModel.blobId)
        if cellModel.blobId == 0 {
            QBRequest.user(withID: UInt(chatDialog.recipientID), successBlock: { (response, user) in
                print(response)
                QBRequest.downloadFile(withID: UInt(user.blobID), successBlock: { (response, data) in
                    print(response)
                    print(data)
                    cell.dialogTypeImage.image = UIImage.init(data: data)
                }, statusBlock: { (request, status) in
                    print(request)
                    print(status)
                    
                }, errorBlock: { (response) in
                    print(response)
                })
               
                
            }) { (response) in
                print(response)
                cell.dialogTypeImage.image = UIImage(named: "profilePlaceholder.jpg")
            }
        }
        else {
            QBRequest.downloadFile(withID: UInt(cellModel.blobId), successBlock: { (response, data) in
                print(response)
                print(data)
                cell.dialogTypeImage.image = UIImage.init(data: data)
            }, statusBlock: { (request, status) in
                print(request)
                print(status)
                
            }, errorBlock: { (response) in
                print(response)
            })
        }
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        let chatVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        chatVC.dialog = dialog
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == UITableViewCellEditingStyle.delete else {
            return
        }
        
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.clear)
        let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
            
            // Deletes dialog from server and cache.
            ServicesManager.instance().chatService.deleteDialog(withID: dialog.id!, completion: { (response) -> Void in
                
                guard response.isSuccess else {
                    SVProgressHUD.showError(withStatus: "SA_STR_ERROR_DELETING".localized)
                    print(response.error?.error)
                    return
                }
                
                SVProgressHUD.showSuccess(withStatus: "SA_STR_DELETED".localized)
            })
        }
        
        if dialog.type == QBChatDialogType.private {
            
            deleteDialogBlock(dialog)
            
        }
        else {
            // group
            let occupantIDs = dialog.occupantIDs!.filter({ (number) -> Bool in
                
                return number.uintValue != ServicesManager.instance().currentUser.id
            })
            
            dialog.occupantIDs = occupantIDs
            let userLogin = ServicesManager.instance().currentUser.email ?? ""
            let notificationMessage = "User \(userLogin) " + "SA_STR_USER_HAS_LEFT".localized
            // Notifies occupants that user left the dialog.
            ServicesManager.instance().chatService.sendNotificationMessageAboutLeaving(dialog, withNotificationText: notificationMessage, completion: { (error) -> Void in
                deleteDialogBlock(dialog)
            })
        }

        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "SA_STR_DELETE".localized
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){
        
        self.reloadTableViewIfNeeded()
    }
    
    // MARK: QMChatConnectionDelegate
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        SVProgressHUD.showError(withStatus: "SA_STR_DISCONNECTED".localized)
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType:.clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    func chatService(_ chatService: QMChatService,chatDidNotConnectWithError error: Error){
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType: .clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    // MARK: - Helpers
    func reloadTableViewIfNeeded() {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.tblViewDialogs.reloadData()
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
