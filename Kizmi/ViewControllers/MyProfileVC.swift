//
//  MyProfileVC.swift
//  Kizmi
//
//  Created by Technorizen on 2/2/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit

class MyProfileVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblfullname: UILabel!
    @IBOutlet weak var lblWork: UILabel!
    @IBOutlet weak var lblSchool: UILabel!
    var dictProfile : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func didTappedonGoToHome(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetProfileDetail()
    }
    // MARK: - Get Profile detail API
    func GetProfileDetail() {
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)get_profile?user_id=\(UserDefaults.standard.value(forKey: "UserId")!)", controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
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
                        self.dictProfile  = responseDict["result"] as! NSDictionary
                        self.lblfullname.text = self.dictProfile.value(forKey: "first_name") as? String
                        
                        let strImage = self.dictProfile.value(forKey: "image") as! String
                        let downloadURL = NSURL(string: strImage)
                        self.imgProfile.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.lblName.text = "Swipe with Friends"
        cell.lblDes.text = "Match with group of friends nearby."
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }

    @IBAction func didTappedonSettings(_ sender: Any) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        child.dictProfile = dictProfile
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(child, animated: false)
    }
    @IBAction func didTappedonEditInfo(_ sender: Any) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "EdiProfileVC") as! EdiProfileVC
        child.dictProfile = dictProfile
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(child, animated: false)
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
