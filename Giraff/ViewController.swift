//
//  ViewController.swift
//  Giraff
//
//  Created by David Newman on 2/4/15.
//  Copyright (c) 2015 Assembly. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZLSwipeableViewDataSource, ZLSwipeableViewDelegate {
    @IBOutlet weak var swipeableView: ZLSwipeableView!

    var gifUrls = [
        "http://i.imgur.com/3Xc2B4f.gif",
        "http://i.imgur.com/icXkt37.gif",
        "http://i.imgur.com/1SSVsBH.gif",
        "http://i.imgur.com/J8MZcVv.gif",
        "http://i.imgur.com/7CZby9V.gif"
    ]
    var gifs:NSMutableArray = []
    var gifIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        swipeableView.dataSource = self
        swipeableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        swipeableView.setNeedsLayout()
        swipeableView.layoutIfNeeded()
    }
    
    // ZLSwipeableViewDelegate
    func swipeableView(swipeableView: ZLSwipeableView!, didStartSwipingView view: UIView!, atLocation location: CGPoint) {
        NSLog("swipe start")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didEndSwipingView view: UIView!, atLocation location: CGPoint) {
        NSLog("swipe end")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeLeft view: UIView!) {
        NSLog("did swipe left")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, didSwipeRight view: UIView!) {
        NSLog("did swipe right")
    }
    
    func swipeableView(swipeableView: ZLSwipeableView!, swipingView view: UIView!, atLocation location: CGPoint, translation: CGPoint) {
    }
    
    // ZLSwipeableViewDataSource
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView!) -> UIView! {
        if (self.gifIndex < self.gifUrls.count) {
            var view = GifView(frame: swipeableView.bounds)
            view.gifUrl = self.gifUrls[self.gifIndex]

            self.gifIndex++

            view.layer.backgroundColor = UIColor.whiteColor().CGColor
            view.layer.shadowColor = UIColor.blackColor().CGColor
            view.layer.shadowOpacity = 0.33
            view.layer.shadowOffset = CGSizeMake(0, 1.5)
            view.layer.shadowRadius = 4.0
            view.layer.shouldRasterize = true
            
            // Corner Radius
            view.layer.cornerRadius = 10.0;
            
            return view
        }
        return nil
    }
}

