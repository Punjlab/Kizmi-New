//
//  SettingViewController.swift
//  Kizmi
//
//  Created by Technorizen on 2/2/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import RangeSeekSlider

class SettingVC : UIViewController {
    var dictProfile : NSDictionary!
    @IBOutlet var ageSlider: RangeSeekSlider!
    @IBOutlet var distanceSlider: RangeSeekSlider!
    @IBOutlet var switchMEn: UISwitch!
    @IBOutlet var switchBoth: UISwitch!
    @IBOutlet var switchWomen: UISwitch!
    var strGender : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ageSlider.delegate = self
        distanceSlider.delegate = self
        ageSlider.selectedMinValue = CGFloat(Int(dictProfile.value(forKey: "st_age_from") as! String)!)
        ageSlider.selectedMaxValue = CGFloat(Int(dictProfile.value(forKey: "st_age_to") as! String)!)
        distanceSlider.selectedMaxValue = CGFloat(Int(dictProfile.value(forKey: "st_distance") as! String)!)
        strGender = dictProfile.value(forKey: "st_gender") as! String
        if strGender == "Female" {
            switchWomen.isOn = true
        }
        else if strGender == "Male" {
            switchMEn.isOn = true
        }
        else{
            switchBoth.isOn = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTappedonDone(_ sender: UIButton) {
        WebHelper.requestGetUrl("\(GlobalConstant.BaseURL)update_setting?user_id=\(UserDefaults.standard.value(forKey: "UserId")!)&st_age_from=\(String(format: "%.0f", ageSlider.selectedMinValue))&st_age_to=\(String(format: "%.0f", ageSlider.selectedMaxValue))&st_distance=\(String(format: "%.0f", distanceSlider.selectedMaxValue))&st_gender=\(strGender)", controllerView: self, success: {(_ response: [AnyHashable: Any]) -> Void in
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
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.type = kCATransitionPush
                        transition.subtype = kCATransitionFromBottom
                        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                        self.navigationController?.view.layer.add(transition, forKey: nil)
                        self.navigationController?.popViewController(animated: false)
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

    @IBAction func didChangeSwitchValue(_ sender: UISwitch) {
        switchBoth.isOn = false
        switchMEn.isOn = false
        switchWomen.isOn = false
        if switchBoth == sender {
            strGender = "Both"
            switchBoth.isOn = true
        }
        else if switchMEn == sender {
            strGender = "Male"
            switchMEn.isOn = true
        }
        else{
            strGender = "Female"
            switchWomen.isOn = true
        }
    }
    @IBAction func didTappedonHelpSupport(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        child.strTitle = sender.title(for: .normal)
        self.navigationController?.pushViewController(child, animated: true)
    }
    @IBAction func didTappedonPrivacyPolicy(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        child.strTitle = sender.title(for: .normal)
        self.navigationController?.pushViewController(child, animated: true)
    }
    @IBAction func didTappedonTermOfService(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        child.strTitle = sender.title(for: .normal)
        self.navigationController?.pushViewController(child, animated: true)
    }
    @IBAction func didTappedonLogout(_ sender: UIButton) {
        let alertController = UIAlertController(title: GlobalConstant.AppName, message: "Are you sure you want to log out?", preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            //Just dismiss the action sheet
            UserDefaults.standard.removeObject(forKey: "UserId")
            UserDefaults.standard.removeObject(forKey: "email")
            let child = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(child, animated: true)
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: { _ in })
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
// MARK: - RangeSeekSliderDelegate

extension SettingVC: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === ageSlider {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
        }
        else if slider === ageSlider {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
