//
//  OopsViewController.swift
//  Fun
//
//  Created by Mikhail Fedosov on 24.02.15.
//  Copyright (c) 2015 Assembly. All rights reserved.
//

import UIKit

class OopsViewController: GAITrackedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Upgrade Proposal"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
