//
//  WebHelper.swift
//  SchoolApp
//
//  Created by Technorizen on 4/29/17.
//  Copyright © 2017 Technorizen. All rights reserved.
//

import UIKit
class WebHelper: NSObject {
    
    
    class func requestPostUrl(_ strURL: String,dictParameter: NSDictionary, controllerView viewController: UIViewController, success: @escaping (_ response: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        MBProgressHUD.hide(for: viewController.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.label.text = "Loading..."
        if GlobalConstant.isReachable() {
            let session = URLSession.shared
            let postData = try? JSONSerialization.data(withJSONObject: dictParameter, options: .prettyPrinted)
            let saveString = String(data: postData!, encoding: String.Encoding.utf8)
            print(saveString!);
            let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            print(strURL);
            let urlPath = URL(string: urlwithPercentEscapes!)
            
            let request = NSMutableURLRequest(url: urlPath! as URL)
            request.timeoutInterval = 60
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: viewController.view, animated: true)
                    }
                }
                
                if((error) != nil) {
                    print(error!.localizedDescription)
                    failure(error)
                }else {
                    _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                    let _: NSError?
                    let jsonResult = try? JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if (jsonResult is NSDictionary) {
                        success(jsonResult as! [AnyHashable : Any])
                    }
                    else{
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: viewController.view, animated: true)
                            GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "JSON text did not start with array or object and option to allow fragments not set.", on: viewController)
                        }
                        
                    }
                }
                
            })
            
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "Internet not connected", on: viewController)
            }
            
        }
    }
    
    class func requestGetUrl(_ strURL: String, controllerView viewController: UIViewController, success: @escaping (_ response: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        MBProgressHUD.hide(for: viewController.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.label.text = "Loading..."
        if GlobalConstant.isReachable() {
            let session = URLSession.shared
            
            let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            print(urlwithPercentEscapes!);
            let urlPath = URL(string: urlwithPercentEscapes!)
            
            let request = NSMutableURLRequest(url: urlPath! as URL)
            request.timeoutInterval = 60
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: viewController.view, animated: true)
                    }
                }
                
                if((error) != nil) {
                    print(error!.localizedDescription)
                    failure(error)
                }else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("error \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 200 || httpResponse.statusCode == 208 {
                            _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                            let _: NSError?
                            let jsonResult = try? JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers)
                            
                            if (jsonResult is NSDictionary) {
                                success(jsonResult as! [AnyHashable : Any])
                            }
                            else{
                                DispatchQueue.main.async {
                                    MBProgressHUD.hide(for: viewController.view, animated: true)
                                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "JSON text did not start with array or object and option to allow fragments not set.", on: viewController)
                                }
                                
                            }
                        }
                        else{
                            failure(error)
                        }
                    }
                    
                    
                }
                
            })
            
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "Internet not connected", on: viewController)
            }
            
        }
    }
    class func requestGetMethodWithoutHUDandView(_ strURL: String, success: @escaping (_ response: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        if GlobalConstant.isReachable() {
            let session = URLSession.shared
            
            let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            print(urlwithPercentEscapes!);
            let urlPath = URL(string: urlwithPercentEscapes!)
            
            let request = NSMutableURLRequest(url: urlPath! as URL)
            request.timeoutInterval = 60
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                    }
                }
                
                if((error) != nil) {
                    print(error!.localizedDescription)
                    failure(error)
                }else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("error \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 200 || httpResponse.statusCode == 208 {
                            _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                            let _: NSError?
                            let jsonResult = try? JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers)
                            
                            if (jsonResult is NSDictionary) {
                                success(jsonResult as! [AnyHashable : Any])
                            }
                            else{
                                DispatchQueue.main.async {
                                }
                                
                            }
                        }
                        else{
                            failure(error)
                        }
                    }
                    
                    
                }
                
            })
            
            task.resume()
        }
        else {
            DispatchQueue.main.async {
            }
            
        }
    }
    class func requestPostUrlWithProfile(_ strURL: String,imageParamName: String,imageData:Data, controllerView viewController: UIViewController, success: @escaping (_ response: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        MBProgressHUD.hide(for: viewController.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.label.text = "Loading..."
        if GlobalConstant.isReachable() {
            let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            print(urlwithPercentEscapes!);
            let url = URL(string: urlwithPercentEscapes!)
            
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = NSMutableData()
            let fname = "test654321.png"
            let mimetype = "image/png"
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"\(imageParamName)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            
            request.httpBody = body as Data
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: viewController.view, animated: true)
                    }
                }
                
                if((error) != nil) {
                    print(error!.localizedDescription)
                    failure(error)
                }else {
                    let response = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                    print(response!)
                    let _: NSError?
                    let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    success(jsonResult as! [AnyHashable : Any])
                }
                
            })
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "Internet not connected", on: viewController)
            }
            
        }
    }
    class func requestPostUrlWithMultipleImages(_ strURL: String,imageParamName: String,imageArray:NSArray, controllerView viewController: UIViewController, success: @escaping (_ response: [AnyHashable: Any]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        MBProgressHUD.hide(for: viewController.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.label.text = "Loading..."
        if GlobalConstant.isReachable() {
            let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            print(urlwithPercentEscapes!);
            let url = URL(string: urlwithPercentEscapes!)
            
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = NSMutableData()
            let fname = "test654321.png"
            let mimetype = "image/png"
            
            for i in 0..<imageArray.count {
                let dictData = imageArray.object(at: i) as! NSDictionary
                var position = dictData.value(forKey: "position") as! Int
                position = position-1
                var paramName = imageParamName
                if position != 0 {
                    paramName = "\(imageParamName)\(position)"
                }
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition:form-data; name=\"\(paramName)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(dictData.value(forKey: "image") as! Data)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            }
            
            request.httpBody = body as Data
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: viewController.view, animated: true)
                    }
                }
                
                if((error) != nil) {
                    print(error!.localizedDescription)
                    failure(error)
                }else {
                    let response = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                    print(response!)
                    let _: NSError?
                    let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    success(jsonResult as! [AnyHashable : Any])
                }
                
            })
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
                GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "Internet not connected", on: viewController)
            }
            
        }
    }

}
