//
//  GlobalConstant.swift
//  Quick Moves
//
//  Created by Technorizen on 6/14/17.
//  Copyright © 2017 Technorizen. All rights reserved.
//

import UIKit
import Reachability
import CoreLocation


class GlobalConstant: NSObject {
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    static let  AppName = "Kizmi"
    static let  BaseURL = "http://mobileappdevelop.co/KIZMI/webservice/"
    static let  Terms   = "http://mobileappdevelop.co/KIZMI/admin/view_page/terms"
    static let  Privacy   = "http://mobileappdevelop.co/KIZMI/admin/view_page/privacy"
    static let  Contact   = "http://mobileappdevelop.co/KIZMI/admin/view_page/contact"
    static let Google_API_KEY  = "AIzaSyAKr17Fbj7HBZlLTNoEOpo0kyCl1aKpFbQ"
    // Messages
    static let  MSGServerError = "Server have some error. Please try again letter!"
    static let  MSGCreateGroupContacts              = "Please select at least one contact"
    
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    
    
    
    class func showAlertMessage(withOkButtonAndTitle strTitle: String, andMessage strMessage: String, on controller: UIViewController) {
        
        let alertController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        controller.present(alertController, animated: true, completion: nil)
        
    }
    class func isReachable() -> Bool {
        let reach = Reachability(hostname: "www.google.com")
        return reach!.isReachable
    }
    class func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")
        return passwordTest.evaluate(with: password)
    }
    class func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    class func verifyUrl (_ urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    class func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class func convertDateStringFromDate(_ fromFormate : String, toFormate : String, strDate : String)-> String {
        
        let dateFormate : DateFormatter = DateFormatter()
        dateFormate.dateFormat = fromFormate
        let date : Date = dateFormate.date(from: strDate)!
        dateFormate.dateFormat = toFormate
        return dateFormate.string(from: date)
    }
    
    class func getStringDateFromDateWithFormat(strFormate : String)-> String {
        
        let dateFormate : DateFormatter = DateFormatter()
        dateFormate.dateFormat = strFormate
        return dateFormate.string(from: Date())
    }
    
    class func getStringDateWithFormat(strFormate : String,date : Date)-> String {
        
        let dateFormate : DateFormatter = DateFormatter()
        dateFormate.dateFormat = strFormate
        return dateFormate.string(from: date)
    }
    class func calicuateYearsBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .year, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .year, in: .era, for: end) else {
            return 0
        }
        return  start - end
    }
    class func getCountryCodeDictionary(strCode : String) -> String {
        let dict : NSDictionary = ["IL" : "972","AF" : "93","AL" : "355","DZ" : "213","AS" : "1","AD" : "376","AO" : "244","AI" : "1","AG" : "1","AR" : "54","AM" : "374","AW" : "297","AU" : "61","AT" : "43","AZ" : "994","BS" : "1","BH" : "973","BD" : "880","BB" : "1","BY" : "375","BE" : "32","BZ" : "501","BJ" : "229","BM" : "1","BT" : "975","BA" : "387","BW" : "267","BR" : "55","IO" : "246","BG" : "359","BF" : "226","BI" : "257","KH" : "855","CM" : "237","CA" : "1","CV" : "238","KY" : "345","CF" : "236","TD" : "235","CL" : "56","CN" : "86","CX" : "61","CO" : "57","KM" : "269","CG" : "242","CK" : "682","CR" : "506","HR" : "385","CU" : "53","CY" : "537","CZ" : "420","DK" : "45","DJ" : "253","DM" : "1","DO" : "1","EC" : "593","EG" : "20","SV" : "503","GQ" : "240","ER" : "291","EE" : "372","ET" : "251","FO" : "298","FJ" : "679","FI" : "358","FR" : "33","GF" : "594","PF" : "689","GA" : "241","GM" : "220","GE" : "995","DE" : "49","GH" : "233","GI" : "350","GR" : "30","GL" : "299","GD" : "1","GP" : "590","GU" : "1","GT" : "502","GN" : "224","GW" : "245","GY" : "595","HT" : "509","HN" : "504","HU" : "36","IS" : "354","IN" : "91","ID" : "62","IQ" : "964","IE" : "353","IL" : "972","IT" : "39","JM" : "1","JP" : "81","JO" : "962","KZ" : "77","KE" : "254","KI" : "686","KW" : "965","KG" : "996","LV" : "371","LB" : "961","LS" : "266","LR" : "231","LI" : "423","LT" : "370","LU" : "352","MG" : "261","MW" : "265","MY" : "60","MV" : "960","ML" : "223","MT" : "356","MH" : "692","MQ" : "596","MR" : "222","MU" : "230","YT" : "262","MX" : "52","MC" : "377","MN" : "976","ME" : "382","MS" : "1","MA" : "212","MM" : "95","NA" : "264","NR" : "674","NP" : "977","NL" : "31","AN" : "599","NC" : "687","NZ" : "64","NI" : "505","NE" : "227","NG" : "234","NU" : "683","NF" : "672","MP" : "1","NO" : "47","OM" : "968","PK" : "92","PW" : "680","PA" : "507","PG" : "675","PY" : "595","PE" : "51","PH" : "63","PL" : "48","PT" : "351","PR" : "1","QA" : "974","RO" : "40","RW" : "250","WS" : "685","SM" : "378","SA" : "966","SN" : "221","RS" : "381","SC" : "248","SL" : "232","SG" : "65","SK" : "421","SI" : "386","SB" : "677","ZA" : "27","GS" : "500","ES" : "34","LK" : "94","SD" : "249","SR" : "597","SZ" : "268","SE" : "46","CH" : "41","TJ" : "992","TH" : "66","TG" : "228","TK" : "690","TO" : "676","TT" : "1","TN" : "216","TR" : "90","TM" : "993","TC" : "1","TV" : "688","UG" : "256","UA" : "380","AE" : "971","GB" : "44","US" : "1","UY" : "598","UZ" : "998","VU" : "678","WF" : "681","YE" : "967","ZM" : "260","ZW" : "263","BO" : "591","BN" : "673","CC" : "61","CD" : "243","CI" : "225","FK" : "500","GG" : "44","VA" : "379","HK" : "852","IR" : "98","IM" : "44","JE" : "44","KP" : "850","KR" : "82","LA" : "856","LY" : "218","MO" : "853","MK" : "389","FM" : "691","MD" : "373","MZ" : "258","PS" : "970","PN" : "872","RE" : "262","RU" : "7","BL" : "590","SH" : "290","KN" : "1","LC" : "1","MF" : "590","PM" : "508","VC" : "1","ST" : "239","SO" : "252","SJ" : "47","SY" : "963","TW" : "886","TZ" : "255","TL" : "670","VE" : "58","VN" : "84","VG" : "1","VI" : "1"]
        return dict.value(forKey: "\(strCode)") as! String
    }
}
