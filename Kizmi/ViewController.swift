//
//  ViewController.swift
//  Kizmi
//
//  Created by Technorizen on 1/23/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import AccountKit
import Alamofire
import AlamofireImage

let appdelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,AKFViewControllerDelegate {
    
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var clcView: UICollectionView!
    var arrImage : NSArray = ["pic.png","pic1.png","pic2.png","pic3.png"]
    var arrTitle1 : NSArray = ["Discover new and interesting","pic1.png","pic2.png","pic3.png"]
    
    var accountKit: AKFAccountKit!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // initialize Account Kit
        if accountKit == nil {
            // may also specify AKFResponseTypeAccessToken
            self.accountKit = AKFAccountKit(responseType: AKFResponseType.accessToken)
        }
        if UserDefaults.standard.value(forKey: "email") != nil {
            let user = QBUUser()
            user.email = UserDefaults.standard.value(forKey: "email") as? String
            user.password = "12345678"
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            self.loginToQuickBlox(email: UserDefaults.standard.value(forKey: "email") as! String)
        }
    }
    @IBAction func didTappedonLoginWithPhoneNumber(_ sender: UIButton) {
        let inputState: String = UUID().uuidString
        let afPhone : AKFPhoneNumber = AKFPhoneNumber.init(countryCode: "", phoneNumber: "")
        let viewController:AKFViewController = accountKit.viewControllerForPhoneLogin(with: afPhone, state: inputState)  as! AKFViewController
        viewController.enableSendToFacebook = true
        self.prepareLoginViewController(viewController)
        self.present(viewController as! UIViewController, animated: true, completion: nil)
    }
    // MARK:- AKFViewControllerDelegate
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        print("Login succcess with AccessToken")
        accountKit.requestAccount{
            (account, error) -> Void in
            
            print(account!.accountID)
            if account?.phoneNumber?.phoneNumber != nil {
                //if the user is logged with phone
                let strphoneNumber : String =  account!.phoneNumber!.stringRepresentation()
                print(strphoneNumber)
                DispatchQueue.main.async {
                    self.callingLoginAPI(strphoneNumber: strphoneNumber)
                }
            }
        }
    }
    func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("Login succcess with AuthorizationCode")
        
    }
    private func viewController(_ viewController: UIViewController!, didFailWithError error: NSError!) {
        print("We have an error \(error)")
    }
    func viewControllerDidCancel(_ viewController: UIViewController!) {
        print("The user cancel the login")
    }
    
    func prepareLoginViewController(_ loginViewController: AKFViewController) {
        
        loginViewController.delegate = self
//        loginViewController.setAdvancedUIManager(nil)
//        //Costumize the theme
//        let theme:AKFTheme = AKFTheme.default()
//        theme.headerBackgroundColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
//        theme.headerTextColor = GlobalConstant.hexStringToUIColor("#FD2B52")
//        theme.iconColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
//        theme.inputTextColor = UIColor(white: 0.4, alpha: 1.0)
//        theme.statusBarStyle = .default
//        theme.textColor = UIColor(white: 0.3, alpha: 1.0)
//        theme.titleColor = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1)
//        loginViewController.setTheme(theme)
   
    }
    
    // MARK: - Mobile Number Exist API 
    func callingLoginAPI(strphoneNumber : String) {
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)check_mobile_exist?mobile=\(strphoneNumber)", controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = response as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "Server have some error. Please try again later!", on: self)
                }
            }
            else{
                let status  = responseDict["status"] as! String
                if status == "1" {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        let result = responseDict["result"] as! NSDictionary
                        UserDefaults.standard.set(result["id"] as! String, forKey: "UserId")
                        appdelegate.updateUserLocationToServer()
                        UserDefaults.standard.set(result["email"] as! String, forKey: "email")
                        self.loginToQuickBlox(email: result["email"] as! String)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
                        vc.strMobile = strphoneNumber
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }, failure: {(_ error: Error?) -> Void in
            //error
            DispatchQueue.main.async {
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "Server have some error. Please try again later!", on: self)
            }
        })
    }
    // MARK:- CollectionView Delegate and Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.bgImage.image = UIImage.init(named: arrImage.object(at: indexPath.row) as! String)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageController.currentPage = indexPath.row
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTappedonFacebook(_ sender: UIButton) {
        MBProgressHUD.hide(for: self.view, animated: true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender,birthday,age_range,education"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result!)
                    var gender = "Female"
                    var birthday = ""
                    let next10days = Date().addingTimeInterval(-(18*365*60*60*24))
                    print(next10days)
                    birthday = GlobalConstant.getStringDateWithFormat(strFormate: "yyyy-MM-dd", date: next10days)
                    let dict = result as! NSDictionary
                    if (dict["gender"] as! String) == "male" || (dict["gender"] as! String) == "Male" {
                        gender = "Male"
                    }
                    if dict["age_range"] is NSDictionary {
                        let dictAge = dict["age_range"] as! NSDictionary
                        if dictAge["min"] is Int {
                            let age = dictAge["min"] as! Int
                            if age < 18 {
                                GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "You must be over 18 to register", on: self)
                                MBProgressHUD.hide(for: self.view, animated: true)
                                return
                            }
                            else{
                                let next10days = Date().addingTimeInterval(TimeInterval(-(age*365*60*60*24)))
                                print(next10days)
                                birthday = GlobalConstant.getStringDateWithFormat(strFormate: "yyyy-MM-dd", date: next10days)
                            }
                        }
                    }
                    if let imageURL = ((dict["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        //Download image from imageURL
                        Alamofire.request(imageURL, method: .get).responseImage { response in
                            guard let image = response.result.value else {
                                // Handle error
                                return
                            }
                            // Do stuff with your image
                            self.ApiCallingForLoginWithSoial(social_id: dict.value(forKey: "id")as! String, username: dict.value(forKey: "name")as! String, email: dict.value(forKey: "email")as! String, gender: gender, imgData: UIImageJPEGRepresentation(image, 0.1)!, birthday: birthday)
                        }
                    }
                    else{
                        self.ApiCallingForLoginWithSoial(social_id: dict.value(forKey: "id")as! String, username: dict.value(forKey: "name")as! String, email: dict.value(forKey: "email")as! String, gender: gender, imgData: UIImageJPEGRepresentation(#imageLiteral(resourceName: "profilePlaceholder.jpg"), 0.1)!, birthday: birthday)
                    }
                }
            })
        }
    }
    
    func ApiCallingForLoginWithSoial(social_id : String,username : String,email : String,gender : String, imgData : Data,birthday : String) {
        var ios_register_id = "1234567890"
        if UserDefaults.standard.value(forKey: "ios_register_id") != nil {
            ios_register_id = UserDefaults.standard.value(forKey: "ios_register_id") as! String
        }
        WebHelper.requestPostUrlWithProfile("\(GlobalConstant.BaseURL)social_login?social_id=\(social_id)&email=\(email)&first_name=\(username)&mobile=&ios_register_id=\(ios_register_id)&device_key=\(ios_register_id)&dob=\(birthday)&gender=\(gender)", imageParamName: "image", imageData: imgData, controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = response as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "Server have some error. Please try again later!", on: self)
                }
            }
            else{
                let status  = responseDict["status"] as! String
                if status == "1" {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        let result = responseDict["result"] as! NSDictionary
                        UserDefaults.standard.set(result["id"] as! String, forKey: "UserId")
                        UserDefaults.standard.set(email, forKey: "email")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                        if (responseDict["social_status"] as! String) == "0" {
                            self.loginToQuickBlox(email: email)
                        }
                        else{
                            self.signUpToQuickBlox(fullName: username, email: email, externalUserID: result["id"] as! String,imgData: imgData)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                        GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "\(responseDict["result"]!)", on: self)
                    }
                }
            }
        }, failure: {(_ error: Error?) -> Void in
            //error
            DispatchQueue.main.async {
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "Server have some error. Please try again later!", on: self)
            }
        })
    }
    func loginToQuickBlox(email : String) {
        // Logging to Quickblox REST API and chat.
        let userLogin = QBUUser()
        userLogin.email = email
        userLogin.password = "12345678"
        ServicesManager.instance().logIn(with: userLogin, completion: {
            [weak self] (success,  errorMessage) -> Void in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "\(String(describing: errorMessage!))", on: self!)
                return
            }
            strongSelf.registerForRemoteNotification()
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        })
    }
    func signUpToQuickBlox(fullName : String,email : String,externalUserID : String,imgData : Data) {
        let user = QBUUser()
        user.fullName = fullName
        user.email = email
        user.password = "12345678"
        user.tags = ["dev","qbqa"]
        user.externalUserID = UInt(externalUserID)!
        
        QBRequest.signUp(user, successBlock: { (response, user) in
            if response.isSuccess == true{
                print(response)
                DispatchQueue.main.async {
                    // Logging to Quickblox REST API and chat.
                    let userLogin = QBUUser()
                    userLogin.email = email
                    userLogin.password = "12345678"
                    ServicesManager.instance().logIn(with: userLogin, completion: {
                        [weak self] (success,  errorMessage) -> Void in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        guard success else {
                            return
                        }
                        strongSelf.registerForRemoteNotification()
                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        strongSelf.updatePtofilePickToQuickBlox(imgData: imgData)
                    })
                }
            }
            else{
                print(response)
            }
        }, errorBlock: { (response) in
            print(response.error!)
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: (response.error?.description)!, on: self)
            }
        })
    }
    func updatePtofilePickToQuickBlox(imgData : Data) {
        QBRequest.tUploadFile(imgData, fileName: "profile.png", contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
            print(response)
            print(blob)
            let param = QBUpdateUserParameters.init()
            param.blobID = Int(blob.id)
            param.tags = ["dev","qbqa"]
            QBRequest.updateCurrentUser(param, successBlock: { (response, user) in
                print(response)
                print(user)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(vc, animated: true)
            }, errorBlock: { (response) in
                print(response)
            })
            
        }, statusBlock: { (request, status) in
            print(request)
            print(status)
        }, errorBlock: { (response) in
            print(response)
        })
    }
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOG".localized, maskType: SVProgressHUDMaskType.clear)
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
        SVProgressHUD.dismiss()
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        //TODO: Uncomment
        //        let dialogsController = self.storyboard?.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
        //        let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        //        chatController.dialog = chatDialog
        //
        //        self.navigationController?.viewControllers = [dialogsController, chatController]
    }
    
    func notificationServiceDidFailFetchingDialog() {
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
        // Register for push in iOS 8
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        else {
            // Register for push in iOS 7
            UIApplication.shared.registerForRemoteNotifications(matching: [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert])
        }
    }
}

