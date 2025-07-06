//
//  Place.swift
//  PlaceAutoComplete
//
//  Created by Irfan on 2/24/16.
//  Copyright © 2016 Irfan. All rights reserved.
//

import UIKit

class Place: NSObject {
    var fullName : String? = ""
    var addressLine: String? = ""
    var city : String? = ""
    var province : String? = ""
    var country : String? = ""
    
    override init() {
    }
    
    func initWithJsonDescription(_ description: String) -> Place {
        fullName = description;
        self.setDetailOfPlace(description)
        return self
    }
    
    func setDetailOfPlace(_ description: String) {
        var placeArray = description.components(separatedBy: ",")
        country = placeArray.removeLast()
        if placeArray.count > 0 {
            province = placeArray.removeLast()
        }
        if placeArray.count > 0 {
            city = placeArray.removeLast()
        }
        addressLine = placeArray.joined(separator: ",")
    }
}
