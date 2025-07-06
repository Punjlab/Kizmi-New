//
//  HomeVC.swift
//  Kizmi
//
//  Created by Technorizen on 1/23/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import DMSwipeCards
class HomeVC: UIViewController {
    private var swipeView: DMSwipeCardsView<String>!
    private var count = 0
    var arrPeopels : NSArray = []
    var strOtherUserImg : String = ""
    var radarView : GMRadarView!
    var isRadarViewRemoved : Bool = true
    var timerforDrivetime  : Timer!
    var currentElement : Int = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        /*
         * In this example we're using `String` as a type.
         * You can use DMSwipeCardsView though with any custom class.
         */
        let notificationName = Notification.Name(
            rawValue: "sendToChatMessage")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(self.didTappedChatMessage),
                                       name: notificationName,
                                       object: nil)
        
        self.downloadUserFromQuickBlox()
    }
    func downloadUserFromQuickBlox()  {
        ServicesManager.instance().downloadCurrentEnvironmentUsers(successBlock: { (users) -> Void in
            
        }, errorBlock: { (error) -> Void in
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        self.arrPeopels = []
        self.isRadarViewRemoved = true
        self.GetProfileDetail()
        self.timerforDrivetime = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.GetProfileDetail), userInfo: nil, repeats: true)
    }
    // MARK: - Get Profile detail API
    func GetProfileDetail() {
        WebHelper.requestGetMethodWithoutHUDandView("\(GlobalConstant.BaseURL)get_people?user_id=\(UserDefaults.standard.value(forKey: "UserId")!)", success: {(_ response: [AnyHashable: Any]) -> Void in
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
                        if self.swipeView != nil {
                            self.swipeView.removeFromSuperview()
                        }
                        if self.isRadarViewRemoved == true {
                            self.isRadarViewRemoved = false
                            self.radarView = GMRadarView(frame: self.view.bounds)
                            self.radarView.backgroundColor  = UIColor.clear
                            self.view.addSubview(self.radarView)
                            self.view.sendSubview(toBack: self.radarView)
                        }
                        if responseDict["result"] is NSArray {
                            self.timerforDrivetime.invalidate()
                            self.radarView.removeFromSuperview()
                            self.radarView.isHidden = true
                            self.isRadarViewRemoved = true
                            if self.swipeView != nil {
                                self.swipeView.removeFromSuperview()
                                self.createSwipeView()
                            }
                            else{
                                self.createSwipeView()
                            }
                            self.currentElement = 0
                            self.arrPeopels = responseDict["result"] as! NSArray
                            self.swipeView.addCards((0...(self.arrPeopels.count)-1).map({"\($0)"}), onTop: false)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        if self.isRadarViewRemoved == true {
                            self.isRadarViewRemoved = false
                            self.radarView = GMRadarView(frame: self.view.bounds)
                            self.radarView.backgroundColor  = UIColor.clear
                            self.view.addSubview(self.radarView)
                            self.view.sendSubview(toBack: self.radarView)
                        }
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
    func createSwipeView()  {
        let viewGenerator: (String, CGRect) -> (UIView) = { (element: String, frame: CGRect) -> (UIView) in
            
            print("=======\(element)======")
            let index = Int(element)!

            let dictData = self.arrPeopels.object(at: index) as! NSDictionary
            
            let container = UIView(frame: CGRect(x: 20, y: 20, width: frame.width - 40, height: frame.height - 40))
            
            let imageview = UIImageView(frame: container.bounds)
            imageview.contentMode = UIViewContentMode.scaleAspectFill
            imageview.clipsToBounds = true
            imageview.layer.cornerRadius = 12
            let strImage = dictData.value(forKey: "image") as! String
            let downloadURL = NSURL(string: strImage)
            imageview.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder.jpg"))
            container.addSubview(imageview)
            
            let bottomView = UIView.init(frame: CGRect.init(x: 0, y: container.frame.size.height-150, width: container.frame.size.width, height: 150))
            bottomView.clipsToBounds = true
            bottomView.layer.cornerRadius = 8
            
            let imgBG = UIImageView.init(frame: bottomView.bounds)
            imgBG.backgroundColor = UIColor.black
            imgBG.alpha = 0.65
            bottomView.addSubview(imgBG)
            
            let btnInfo = UIButton.init(frame: CGRect.init(x: bottomView.frame.size.width-40, y: bottomView.frame.size.height-40, width: 35, height: 35))
            btnInfo.tag = Int(element)!
            btnInfo.setImage(#imageLiteral(resourceName: "info.png"), for: .normal)
            btnInfo.addTarget(self, action: #selector(self.didTappedonInfo(_:)), for: .touchUpInside)
            bottomView.addSubview(btnInfo)
            
            let imgWork = UIImageView.init(frame: CGRect.init(x: 15, y: bottomView.frame.size.height-40, width: 15, height: 15))
            imgWork.image = #imageLiteral(resourceName: "profession.png")
            bottomView.addSubview(imgWork)
            
            let lblProfession = UILabel.init(frame: CGRect.init(x: imgWork.frame.size.width+imgWork.frame.origin.x+8, y: imgWork.frame.origin.y-8, width: bottomView.frame.size.width-(imgWork.frame.size.width+imgWork.frame.origin.x+8), height:30))
            lblProfession.text = dictData.value(forKey: "work") as? String
            lblProfession.textColor = UIColor.white
            lblProfession.font = UIFont.init(name: "Helvetica Neue", size: 13)
            bottomView.addSubview(lblProfession)
            
            let imgCollege = UIImageView.init(frame: CGRect.init(x: 15, y: imgWork.frame.origin.y-30, width: 15, height: 15))
            imgCollege.image = #imageLiteral(resourceName: "study.png")
            bottomView.addSubview(imgCollege)
            
            let lblCollege = UILabel.init(frame: CGRect.init(x: imgCollege.frame.size.width+imgCollege.frame.origin.x+8, y: imgCollege.frame.origin.y-8, width: bottomView.frame.size.width-(imgCollege.frame.size.width+imgCollege.frame.origin.x+8), height:30))
            lblCollege.text = dictData.value(forKey: "school") as? String
            lblCollege.textColor = UIColor.white
            lblCollege.font = UIFont.init(name: "Helvetica Neue", size: 13)
            bottomView.addSubview(lblCollege)
            
            
            let imgLocation = UIImageView.init(frame: CGRect.init(x: 15, y: imgCollege.frame.origin.y-30, width: 15, height: 15))
            imgLocation.image = #imageLiteral(resourceName: "location.png")
            bottomView.addSubview(imgLocation)
            
            let lbllocation = UILabel.init(frame: CGRect.init(x: imgLocation.frame.size.width+imgLocation.frame.origin.x+8, y: imgLocation.frame.origin.y-8, width: bottomView.frame.size.width-(imgLocation.frame.size.width+imgLocation.frame.origin.x+8), height:30))
            lbllocation.text = "\(dictData["distance"] as! String) km away from you"
            lbllocation.textColor = UIColor.white
            lbllocation.font = UIFont.init(name: "Helvetica Neue", size: 13)
            bottomView.addSubview(lbllocation)
            
            let lblName = UILabel.init(frame: CGRect.init(x: 15, y: imgLocation.frame.origin.y-35, width: bottomView.frame.size.width-15, height:30))
            lblName.text = "\(dictData["first_name"] as! String), \(dictData["age"] as! Int)"
            lblName.textColor = UIColor.white
            lblName.font = UIFont.init(name: "Helvetica Neue", size: 17)
            bottomView.addSubview(lblName)
            
            container.addSubview(bottomView)
            
            container.layer.cornerRadius = 8
            container.layer.shadowRadius = 4
            container.layer.shadowOpacity = 1.0
            container.layer.shadowColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 0)
            container.layer.shouldRasterize = true
            container.layer.rasterizationScale = UIScreen.main.scale
            
            return container
        }
        
        let overlayGenerator: (SwipeMode, CGRect) -> (UIView) = { (mode: SwipeMode, frame: CGRect) -> (UIView) in
            let label = UILabel()
            label.frame.size = CGSize(width: 100, height: 100)
            label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
            label.layer.cornerRadius = label.frame.width / 2
            label.backgroundColor = mode == .left ? UIColor.red : UIColor.green
            label.clipsToBounds = true
            label.text = mode == .left ? "👎" : "👍"
            label.font = UIFont.systemFont(ofSize: 24)
            label.textAlignment = .center
            return label
        }
        
        let frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height - 160)
        swipeView = DMSwipeCardsView<String>(frame: frame,
                                             viewGenerator: viewGenerator,
                                             overlayGenerator: overlayGenerator)
        swipeView.delegate = self
        self.view.addSubview(swipeView)
    }
    @IBAction func didTappedonInfo(_ sender: UIButton) {
        let child = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as! UserDetailVC
        child.dictProfile = self.arrPeopels.object(at: sender.tag) as! NSDictionary
        child.strFrom = "Home"
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(child, animated: false)
    }
    @IBAction func didTappedonProfile(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @IBAction func didTappedChatMessage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
       
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func DidTappedonLike(_ sender: UIButton) {
        if arrPeopels.count != 0 {
            let dictData = self.arrPeopels.object(at: self.currentElement) as! NSDictionary
            self.didTappedonLike(to_id: dictData.value(forKey: "id") as! String, status: "1", type: "Action")
        }
    }
    @IBAction func didTappedonDisLike(_ sender: UIButton) {
        if arrPeopels.count != 0 {
            let dictData = self.arrPeopels.object(at: self.currentElement) as! NSDictionary
            self.didTappedonLike(to_id: dictData.value(forKey: "id") as! String, status: "0", type: "Action")
        }
        
    }
    @IBAction func didTappedonRefresh(_ sender: UIButton) {
        self.GetProfileDetail()
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
                        let dictResult  = responseDict["result"] as! NSDictionary
                        if (dictResult["type"] as! String) == "match" {
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "MatchVC") as! MatchVC
                            view.strOtherUserImg = self.strOtherUserImg
                            self.present(view, animated: true, completion: nil)
                        }
                        if type == "Action" {
                            self.GetProfileDetail()
                        }
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
    override func viewWillDisappear(_ animated: Bool) {
        if (timerforDrivetime != nil) {
            timerforDrivetime.invalidate()
        }
        self.radarView.removeFromSuperview()
    }
}
extension HomeVC: DMSwipeCardsViewDelegate {
    func swipedLeft(_ object: Any) {
        print("Swiped left: \(object)")
        let dictData = self.arrPeopels.object(at: Int(object as! String)!) as! NSDictionary
        self.didTappedonLike(to_id: dictData.value(forKey: "id") as! String, status: "1", type: "Gesture")
        self.currentElement = self.currentElement+1
    }
    
    func swipedRight(_ object: Any) {
        print("Swiped right: \(object)")
        let dictData = self.arrPeopels.object(at: Int(object as! String)!) as! NSDictionary
        self.strOtherUserImg = dictData.value(forKey: "image") as! String
        self.didTappedonLike(to_id: dictData.value(forKey: "id") as! String, status: "1", type: "Gesture")
        self.currentElement = self.currentElement+1
    }
    
    func cardTapped(_ object: Any) {
        //print("Tapped on: \(object)")
    }
    
    func reachedEndOfStack() {
        print("Reached end of stack")
        self.timerforDrivetime = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.GetProfileDetail), userInfo: nil, repeats: true)
    }
}
