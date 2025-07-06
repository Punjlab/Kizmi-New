//
//  MatchVC.swift
//  Kizmi
//
//  Created by Technorizen on 2/14/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit

class MatchVC: UIViewController {
    var strOtherUserImg : String!
    @IBOutlet var userProfile: UIImageView!
    @IBOutlet var friendProfile: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                        let dictProfile  = responseDict["result"] as! NSDictionary
                        
                        let strImage = dictProfile.value(forKey: "image") as! String
                        let downloadURL = NSURL(string: strImage)
                        self.userProfile.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
                        self.friendProfile.af_setImage(withURL: NSURL(string: self.strOtherUserImg)! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTappedonKeepSwiping(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTappedonSendMessage(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("sendToChatMessage"), object: nil)
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
