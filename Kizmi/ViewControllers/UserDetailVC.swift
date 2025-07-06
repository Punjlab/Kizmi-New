//
//  UserDetailVC.swift
//  Kizmi
//
//  Created by Technorizen on 2/12/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import DropDown
import MessageUI
class UserDetailVC: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate  {
    
    let dropDown = DropDown()
    var strFrom : String!
    var strStrUserID : String!
    @IBOutlet var pageController: UIPageControl!
    var dictProfile : NSDictionary!
    @IBOutlet var clcView: UICollectionView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var lblStudy: UILabel!
    @IBOutlet var lblCollege: UILabel!
    @IBOutlet var lblabout: UILabel!
    var arrImages : NSMutableArray = []
    @IBOutlet var viewLike: UIStackView!
    @IBOutlet var btnMore: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnMore.isHidden = true
        if strFrom == "Chat" {
            viewLike.isHidden = true
            btnMore.isHidden = false
        }
        print(dictProfile)
        lblabout.text = "About : \(dictProfile.value(forKey: "about") as! String)"
        userName.text = dictProfile["first_name"] as? String
        lblStudy.text = "Profession : \(String(describing: dictProfile.value(forKey: "work") as! String))"
        lblCollege.text = "College : \(String(describing: dictProfile.value(forKey: "school") as! String))"
        for i in 0..<6 {
            var param = "image"
            if i != 0 {
                param = "\(param)\(i)"
            }
            let strImage = self.dictProfile.value(forKey: param) as! String
            if strImage.contains(".png") {
                arrImages.add(strImage)
            }
        }
        pageController.numberOfPages = arrImages.count
        clcView.reloadData()
    }
    // MARK:- CollectionView Delegate and Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let strImage = arrImages.object(at: indexPath.row) as! String
        let downloadURL = NSURL(string: strImage)
        cell.bgImage.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
         return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageController.currentPage = indexPath.row
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTappedonBackButton(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func DidTappedonLike(_ sender: UIButton) {
        self.didTappedonLike(to_id: dictProfile.value(forKey: "id") as! String, status: "1", type: "Action")
    }
    @IBAction func didTappedonDisLike(_ sender: UIButton) {
        self.didTappedonLike(to_id: dictProfile.value(forKey: "id") as! String, status: "0", type: "Action")
    }
    func didTappedonLike(to_id : String,status : String, type : String) {
        //http://mobileappdevelop.co/KIZMI/webservice/like_user?from_id=1&to_id=2&status=1
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)like_user?from_id=\(UserDefaults.standard.value(forKey: "UserId")!)&to_id=\(to_id)&status=\(status)", controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = response as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Server have some error. Please try again later!", on: self)
                }
            }
            else{
                let status  = responseDict["status"] as! String
                if status == "1" {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        //                        GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "\(responseDict["message"]!)", on: self)
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
    @IBAction func didTappedonMore(_ sender: UIButton) {
        dropDown.anchorView = sender
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        dropDown.dataSource = ["Report","Block"]
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index, item) in
            if index == 1 {
                self.blockUser()
            }
            else {
                self.reportUser()
            }
        }
        dropDown.show()
    }
    func blockUser(){
        let alertController = UIAlertController(title: GlobalConstant.AppName, message: "Are you sure you want to block \(dictProfile["first_name"] as! String) ?", preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            //Just dismiss the action sheet
            
            ServicesManager.instance().chatService.deleteDialog(withID: self.strStrUserID)
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: DialogsViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: { _ in })
    }
    
    func reportUser()  {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["atinderzaildar@yahoo.com"])
            mail.setSubject("Report User (\(dictProfile["first_name"] as! String)")
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Cannot send mail", on: self)
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case result.rawValue:
            print("Cancelled")
        case result.rawValue:
            print("Saved")
        case result.rawValue:
            print("Sent")
        case result.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
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
