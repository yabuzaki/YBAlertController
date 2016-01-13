//
//  ViewController.swift
//  YBAlertController
//
//  Created by Yabuzaki on 01/13/2016.
//  Copyright (c) 2016 Yabuzaki. All rights reserved.
//

import UIKit
import YBAlertController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func showActionSheet(sender: AnyObject) {
        
        // Action Sheet
        let ybActionSheet = YBAlertController(style: .ActionSheet)
        // add button
        ybActionSheet.addButton(UIImage(named: "comment"), title: "Comment", target: self, selector: Selector("tap"))
        // add button with closure
        ybActionSheet.addButton(UIImage(named: "tweet"), title: "Tweet", action: {
            print("tweetButton tapped")
        })
        ybActionSheet.addButton(UIImage(named: "safari"), title: "Open in Safari", target: self, selector: Selector("tap"))
        
        // custom button icon color
        ybActionSheet.buttonIconColor = UIColor.blackColor()
        // touch outside the alert to dismiss
        ybActionSheet.touchingOutsideDismiss = true
        // show alert
        ybActionSheet.show()
    }
    
    @IBAction func showAlert(sender: AnyObject) {
        
        // Alert
        let alert = YBAlertController(title: "Menu", message: "Message", style: .Alert)
        // add a button (no image)
        alert.addButton("Comment", target: self, selector: Selector("tap"))
        alert.addButton("Tweet", target: self, selector: Selector("tap"))
        alert.addButton("Open", action: {
        })
        // if you use a cancel Button, set cancelButtonTitle
        alert.cancelButtonTitle = "Cancel"
        // show alert
        alert.show()
    }
    
    func tap() {
        print("tap")
    }
    
}

