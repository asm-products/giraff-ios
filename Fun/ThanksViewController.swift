//
//  ThanksViewController.swift
//  Fun
//
//  Created by Mikhail Fedosov on 24.02.15.
//  Copyright (c) 2015 Assembly. All rights reserved.
//

import UIKit

class ThanksViewController: UIViewController {
    
    var parent: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
