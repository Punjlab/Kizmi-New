//
//  AppDelegate.swift
//  Kizmi
//
//  Created by Technorizen on 1/23/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit
import CoreLocation
import IQKeyboardManagerSwift
import UserNotifications

let kQBApplicationID:UInt = 68643
let kQBAuthKey = "Ms8BpsfryBSWwVz"
let kQBAuthSecret = "teUSMfHQWVpYgS-"
let kQBAccountKey = "ZjNRvckCGnAXo8VroxmL"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var lastLocation : CLLocation!
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = kQBApplicationID;
        QBSettings.authKey = kQBAuthKey
        QBSettings.authSecret = kQBAuthSecret
        QBSettings.accountKey = kQBAccountKey
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
        // app was launched from push notification, handling it
        let remoteNotification: NSDictionary! = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
        if (remoteNotification != nil) {
            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
        }
        
        return true
    }
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        return facebookDidHandle
    }
    //MARK: - Location Manager Delegate stuff If failed
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last! as CLLocation
        if UserDefaults.standard.value(forKey: "UserId") != nil {
            self.updateUserLocationToServer()
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token " + deviceTokenString)
        UserDefaults.standard.set(deviceTokenString, forKey: "ios_register_id")
        
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription: QBMSubscription! = QBMSubscription()
        
        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
        }) { (response: QBResponse!) -> Void in
            //
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print("my push is: %@", userInfo)
        guard application.applicationState == UIApplicationState.inactive else {
            if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
            {
                let alertMsg = info["alert"] as! String
                var alert: UIAlertView!
                alert = UIAlertView(title: "Notification", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            return
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        ServicesManager.instance().chatService.connect(completionBlock: nil)
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func updateUserLocationToServer() {
        WebHelper.requestGetMethodWithoutHUDandView("\(GlobalConstant.BaseURL)update_lat_lon?user_id=\(UserDefaults.standard.value(forKey: "UserId")!)&lat=\(lastLocation.coordinate.latitude)&lon=\(lastLocation.coordinate.longitude)",  success: {(_ response: [AnyHashable: Any]) -> Void in
            //Success
            let responseDict = response as NSDictionary
            print("responce:\(responseDict)")
            if  responseDict.count == 0
            {
                DispatchQueue.main.async {
                }
            }
            else{
                let status  = responseDict["status"] as! String
                if status == "1" {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                    }
                }
            }
        }, failure: {(_ error: Error?) -> Void in
            //error
            DispatchQueue.main.async {
            }
        })
    }

}

