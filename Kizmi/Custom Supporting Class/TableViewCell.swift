//
//  TableViewCell.swift
//  VCARDY
//
//  Created by Technorizen on 8/10/17.
//  Copyright © 2017 Technorizen. All rights reserved.
//

import UIKit
import AlamofireImage
class TableViewCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var imgBG: UIImageView!
    
    @IBOutlet var btnContact: UIButton!

    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblPriceFor: UILabel!
    @IBOutlet var lblAdd: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    // MARK:- ProductList
    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblDealPrice: UILabel!
    @IBOutlet var lblSave: UILabel!
    @IBOutlet var customerReview: UILabel!
    @IBOutlet var lblClaimedDeal: UILabel!
    @IBOutlet var btnAddTocart: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:- Set Product Item
    func setItem(dictItem : NSDictionary)  {
        print(dictItem)
        let strImage = dictItem["product_image"] as! String
        let downloadURL = NSURL(string: strImage)
        imgProduct.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "noImagePlaceHolder.jpg"))
        lblProductName.text = dictItem["product_name"] as? String
        lblDescription.text = dictItem["description"] as? String
        lblPrice.text = "Price : $ \(dictItem["price"] as! String)"
    }
    //MARK:- Set Category
    func setCategory(dictItem : NSDictionary)  {
        print(dictItem)
        let strImage = dictItem["category_image"] as! String
        let downloadURL = NSURL(string: strImage)
        imgProduct.af_setImage(withURL: downloadURL! as URL, placeholderImage: #imageLiteral(resourceName: "noImagePlaceHolder.jpg"))
        lblProductName.text = "\t\(dictItem["category_name"] as! String)\t"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
