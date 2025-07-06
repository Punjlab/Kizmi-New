//
//  EdiProfileVC.swift
//  Kizmi
//
//  Created by Technorizen on 2/12/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class EdiProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate {
    var dictProfile : NSDictionary!
    var imagePicker = UIImagePickerController()
    @IBOutlet var BtnImage: [UIButton]!
    var arrImages : NSMutableArray = []
    var selectedPicker : Int = 0
    @IBOutlet var lblAbout: UILabel!
    @IBOutlet var txtViewAbout: UITextView!
    @IBOutlet var txtWork: UITextField!
    @IBOutlet var txtSchool: UITextField!
    @IBOutlet var segmentGender: UISegmentedControl!
    var strGender : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(dictProfile)
        lblAbout.text = "About \(dictProfile.value(forKey: "first_name") as! String)"
        txtViewAbout.text = dictProfile["about"] as! String
        txtSchool.text = dictProfile["school"] as? String
        txtWork.text = dictProfile["work"] as? String
        strGender = dictProfile["gender"] as! String
        if (dictProfile["gender"] as! String) == "Male" {
            segmentGender.selectedSegmentIndex = 0
        }
        else{
            segmentGender.selectedSegmentIndex = 1
        }
        for i in 0..<6 {
            var param = "image"
            if i != 0 {
                param = "\(param)\(i)"
            }
            let strImage = self.dictProfile.value(forKey: param) as! String
            //Download image from imageURL
            Alamofire.request(strImage, method: .get).responseImage { response in
                guard let image = response.result.value else {
                    // Handle error
                    return
                }
                // Do stuff with your image
                self.BtnImage.forEach({ (singleBtn) in
                    if singleBtn.tag == i+1 {
                        singleBtn.setBackgroundImage(image, for: .normal)
                        singleBtn.setImage(#imageLiteral(resourceName: "close.png"), for: .normal)
                    }
                })
            }
        }
        txtWork.setLeftPaddingPoints(8)
        txtSchool.setLeftPaddingPoints(8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func DidPickImageFromGalleryORCamera(_ sender: UIButton) {
        selectedPicker = sender.tag
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
            self.BtnImage.forEach({ (singleBtn) in
                if singleBtn.tag == selectedPicker {
                    singleBtn.setBackgroundImage(image, for: .normal)
                    singleBtn.setImage(#imageLiteral(resourceName: "close.png"), for: .normal)
                    let dictData : NSMutableDictionary = [:]
                    dictData.setValue(UIImageJPEGRepresentation(image, 0.1), forKey: "image")
                    dictData.setValue(selectedPicker, forKey: "position")
                    arrImages.add(dictData)
                }
            })
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func ChangeSegmentofGender(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            strGender = "Male"
        }
        else{
            strGender = "Female"
        }
    }
    
    @IBAction func didTappedonSave(_ sender: UIButton) {
        WebHelper.requestPostUrlWithMultipleImages("\(GlobalConstant.BaseURL)update_profile?user_id=\(UserDefaults.standard.value(forKey: "UserId")!)&school=\(txtSchool.text!)&work=\(txtWork.text!)&about=\(txtViewAbout.text!)&gender=\(strGender)", imageParamName: "image", imageArray: arrImages, controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
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
                        for i in 0..<self.arrImages.count {
                            let dictData = self.arrImages.object(at: i) as! NSDictionary
                            var position = dictData.value(forKey: "position") as! Int
                            position = position-1
                            if position == 0 {
                                self.updatePtofilePickToQuickBlox(imgData: dictData.value(forKey: "image") as! Data)
                            }
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
    @IBAction func didTappedonBack(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
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
