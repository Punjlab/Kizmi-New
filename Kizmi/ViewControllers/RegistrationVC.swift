//
//  RegistrationVC.swift
//  Kizmi
//
//  Created by Technorizen on 1/31/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit

class RegistrationVC: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker = UIImagePickerController()
    var passwordStrength: PasswordStrengthView!
    var strMobile : String!
    @IBOutlet var txtEmailaddress: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var constPasswordLeading: NSLayoutConstraint!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var constLeadingNameView: NSLayoutConstraint!
    var strDate : String = ""
    var strGender : String = ""
    
    @IBOutlet var btnBirthday: UIButton!
    @IBOutlet var constLeadingBirthdayView: NSLayoutConstraint!
    @IBOutlet var viewPicker: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var constLeadingGenderView: NSLayoutConstraint!
    @IBOutlet var btnWoman: UIButton!
    @IBOutlet var btnMAn: UIButton!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var constLeadingPickPhoto: NSLayoutConstraint!
    var isAcceptTerms : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTappedonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTappedonSignUp(_ sender: UIButton) {
        if txtEmailaddress.text == "" || GlobalConstant.isValidEmail(txtEmailaddress.text!) == false {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please enter valid email address.", on: self)
            return
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constPasswordLeading.constant =  0;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonBackToEmailView(_ sender: Any) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constPasswordLeading.constant =  500;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    
    @IBAction func didTappedonPasswordContinue(_ sender: Any) {
        if txtPassword.text == "" {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please enter password.", on: self)
            return
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingNameView.constant =  0;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    
    @IBAction func didTappedonBackToPasswordView(_ sender: Any) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingNameView.constant =  500;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonFullNameContinue(_ sender: Any) {
        if txtName.text == "" {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please enter your full name.", on: self)
            return
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingBirthdayView.constant =  0;
                        self.view.endEditing(true)
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }

    @IBAction func didTappedonBackToFullNAmeView(_ sender: Any) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingBirthdayView.constant =  500;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    
    @IBAction func didTappedonClickToPickBirthday(_ sender: Any) {
        viewPicker.isHidden = false
        datePicker.maximumDate = Date()
    }
    @IBAction func didChangeDate(_ sender: UIDatePicker) {
        strDate = GlobalConstant.getStringDateWithFormat(strFormate: "yyyy-MM-dd", date: sender.date)
        btnBirthday.setTitle(strDate, for: UIControlState.normal)
        btnBirthday.setTitleColor(UIColor.black, for: UIControlState.normal)
    }
    @IBAction func didTappedonDone(_ sender: Any) {
        viewPicker.isHidden = true
    }
    @IBAction func didTappedonontinueBirthday(_ sender: Any) {
        if strDate == "" {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please choose date of birth.", on: self)
            return
        }
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let birthDate = format.date(from: strDate)
        
        let diff = GlobalConstant.calicuateYearsBetweenTwoDates(start: today, end: birthDate!)
        if diff < 18 {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "You must be over 18 to register", on: self)
            return
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingGenderView.constant =  0;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonBackToBirthdayView(_ sender: Any) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingGenderView.constant =  500;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonSelectWoman(_ sender: Any) {
        btnMAn.setTitleColor(UIColor.gray, for: UIControlState.normal)
        btnMAn.layer.borderColor = UIColor.lightGray.cgColor
        strGender = "Male"
        btnWoman.setTitleColor(GlobalConstant.hexStringToUIColor("FD2B52"), for: UIControlState.normal)
        btnWoman.layer.borderColor = GlobalConstant.hexStringToUIColor("FD2B52").cgColor
    }
    @IBAction func didTappedonSelectMan(_ sender: Any) {
        btnMAn.setTitleColor(GlobalConstant.hexStringToUIColor("FD2B52"), for: UIControlState.normal)
        btnMAn.layer.borderColor = GlobalConstant.hexStringToUIColor("FD2B52").cgColor
        strGender = "Female"
        btnWoman.setTitleColor(UIColor.gray, for: UIControlState.normal)
        btnWoman.layer.borderColor = UIColor.lightGray.cgColor
    }
    @IBAction func didTappedonContinueFromGenderView(_ sender: Any) {
        if strGender == "" {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please choose your gender.", on: self)
            return
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingPickPhoto.constant =  0;
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonBacktoGenderView(_ sender: Any) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constLeadingPickPhoto.constant =  500
                        self.view.endEditing(true)
                        self.view?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    @IBAction func didTappedonPickImage(_ sender: Any) {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Pick Image", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Annuleer")
            self.dismiss(animated: true, completion: nil)
            
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            print("Camera")
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else{
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Camera not available", on: self)
            }
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Gallery", style: .default)
        { _ in
            print("Galerij")
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else{
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Gallery not available", on: self)
            }
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfile.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTappedonDONEPICK(_ sender: Any) {
        if imgProfile.image == nil {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please choose profile picture!", on: self)
            return
        }
        if  isAcceptTerms == false {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: GlobalConstant.AppName, andMessage: "Please accept terms & condition!", on: self)
            return
        }
        WebHelper.requestPostUrlWithProfile("\(GlobalConstant.BaseURL)signup?first_name=\(txtName.text!)&mobile=\(strMobile!)&email=\(txtEmailaddress.text!)&password=\(txtPassword.text!)&dob=\(strDate)&gender=\(strGender)", imageParamName: "image", imageData: UIImageJPEGRepresentation(imgProfile.image!, 0.1)!, controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
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
                        self.signUpToQuickBlox(fullName: self.txtName.text!, email: self.txtEmailaddress.text!, externalUserID: result["id"] as! String)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        GlobalConstant.showAlertMessage(withOkButtonAndTitle: "\(GlobalConstant.AppName)", andMessage: "\(responseDict["message"]!)", on: self)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
         if txtPassword == textField {
            if (passwordStrength == nil) {
                let frame = CGRect(x: txtPassword.frame.origin.x, y: txtPassword.frame.origin.y + txtPassword.frame.size.height+2, width: txtPassword.frame.size.width, height: 10)
                print(txtPassword.frame.origin.y)
                passwordStrength = PasswordStrengthView(frame: frame)
                passwordStrength.enableHints = false
                passwordView.addSubview(passwordStrength)
            }
            print(txtPassword.frame.origin.y)
            let textFieldText: NSString = textField.text as NSString? ?? ""
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            
            _ = passwordStrength.updateStrength(password: txtAfterUpdate)
        }
        return true
    }
    func signUpToQuickBlox(fullName : String,email : String,externalUserID : String) {
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
                        strongSelf.updatePtofilePickToQuickBlox()
                        strongSelf.registerForRemoteNotification()
                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        
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
    func updatePtofilePickToQuickBlox() {
        QBRequest.tUploadFile(UIImageJPEGRepresentation(imgProfile.image!, 0.1)!, fileName: "profile.png", contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
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
    @IBAction func didTapppedonTermsCondtion(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        child.strTitle = sender.title(for: .normal)
        self.navigationController?.pushViewController(child, animated: true)
    }
    @IBAction func didTapppedonPrivacy(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        child.strTitle = sender.title(for: .normal)
        self.navigationController?.pushViewController(child, animated: true)
    }
    @IBAction func didTapppedonAccept(_ sender: UIButton) {
        if isAcceptTerms == false {
            isAcceptTerms = true
            sender.setImage(#imageLiteral(resourceName: "success.png"), for: .normal)
        }
        else{
            isAcceptTerms = false
            sender.setImage(#imageLiteral(resourceName: "empty.png"), for: .normal)
        }
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
