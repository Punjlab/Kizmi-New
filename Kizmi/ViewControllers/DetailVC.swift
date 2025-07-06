//
//  DetailVC.swift
//  Kizmi
//
//  Created by Technorizen on 2/3/18.
//  Copyright © 2018 Technorizen. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    var strTitle : String!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTitle.text = strTitle
        if strTitle == "Help & Support" {
            webview.loadRequest(URLRequest.init(url: URL.init(string: GlobalConstant.Contact)!))
        }
        else if strTitle == "Privacy Policy" {
            webview.loadRequest(URLRequest.init(url: URL.init(string: GlobalConstant.Privacy)!))
        }
        else{
            webview.loadRequest(URLRequest.init(url: URL.init(string: GlobalConstant.Terms)!))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTappedonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
