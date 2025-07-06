//
//  GooglePlaceQuery.swift
//  PlaceAutoComplete
//
//  Created by Irfan on 2/24/16.
//  Copyright © 2016 Irfan. All rights reserved.
//

import UIKit

let API_KEY  = "\(GlobalConstant.Google_API_KEY)" // Need to be replaced with google api key for your own project
//let API_KEY  = "AIzaSyCuCT2vj2sOB6dE-MflTWjCpglhFWZsccE" // Need to be replaced with google api key for your own project  --------- From Our Account

class GooglePlaceQuery: NSObject {
    var input: String? = ""
    
    func executeServiceQuery(_ success: @escaping (_ resultantPlaces: Array<Place>) -> Void, failure: @escaping (_ error: String) -> Void) {
        var url : URL!
        if(!API_KEY.isEmpty) {
            url = self.getUrl()
        } else {
            failure("Invalid API KEY")
        }
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                failure(error!.localizedDescription)
            } else {
                let response: HTTPURLResponse = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    failure("Google Places Error: Invalid status code\(response.statusCode) from API")
                    return
                }
                let places = self.parseServerResponse(data!)
                success(places)
            }
        }) 
        dataTask.resume()
    }
    
    func getUrl() -> URL {
        //=country%3ACA%7Ccountry%3AUS
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let urlString = String(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?location=%f,%f&radius=1200&input=%@&key=%@&sensor=true", arguments:[appDelegate.lastLocation.coordinate.latitude,appDelegate.lastLocation.coordinate.latitude,escape(input!), API_KEY])
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        print(urlwithPercentEscapes!);
        print(URL(string: urlwithPercentEscapes!)!)
        return URL(string: urlwithPercentEscapes!)!
    }
    
    fileprivate func escape(_ string: String) -> String {
        return string.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    func parseServerResponse(_ data: Data) -> Array<Place> {
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        }
        catch {
            json = nil
            print("GooglePlaces Error")
            return Array<Place>()
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                return Array<Place>()
            }
        }
        return self.getParsedPlaces((json!["predictions"] as? NSArray)!)
    }
    
    func getParsedPlaces(_ dict: NSArray) -> Array<Place> {
        var places = Array<Place>()
        for item in dict {
            let dictt : NSDictionary = item as! NSDictionary
            let place = Place()
            let placeDescription = dictt["description"] as! String
            place.initWithJsonDescription(placeDescription)
            places.append(place)
        }
        return places
    }
    
    func catchError() {
        print("Error could not parse JSON:")
    }
    
    func canValidateAllFields() -> Bool {
        return true
    }
}
