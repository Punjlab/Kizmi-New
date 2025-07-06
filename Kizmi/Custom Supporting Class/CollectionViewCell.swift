//
//  CollectionViewCell.swift
//  VCARDY
//
//  Created by Technorizen on 8/10/17.
//  Copyright © 2017 Technorizen. All rights reserved.
//

import UIKit
import SwiftyStarRatingView
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var imgVerified: UIImageView!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var imgCrossIcon: UIImageView!
    
    // Restaurant    
    @IBOutlet var btnReserve: UIButton!
    @IBOutlet var btnFindOutMore: UIButton!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var rateView: SwiftyStarRatingView!
    @IBOutlet var lblRateCount: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblDes: UILabel!
    
    @IBOutlet var btnPrice: UIButton!
    
    
    //MARK:- Set Product Item
    func setRestaurant(dictItem : NSDictionary)  {
        let strImage = dictItem["logo_image"] as! String
        let downloadURL = NSURL(string: strImage)
        bgImage.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "noImagePlaceHolder.jpg"))
        lblName.text = dictItem["name"] as? String
        lblLocation.text = "Restaurant : \(dictItem["address"] as! String)"
        lblDes.text = dictItem["description"] as? String
    }
    
    //MARK:- Set Product Item
    func setMenu(dictItem : NSDictionary)  {
        let strImage = dictItem["item_image"] as! String
        let downloadURL = NSURL(string: strImage)
        bgImage.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "noImagePlaceHolder.jpg"))
        lblName.text = dictItem["item_name"] as? String
        lblDes.text = dictItem["description"] as? String
        btnPrice.setTitle("  $\(dictItem["item_price"] as! String)  ", for: UIControlState.normal)
    }
}
