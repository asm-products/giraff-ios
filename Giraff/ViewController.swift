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
        NSLog("swiping at location: x %f, y %f, translation: x %f, y %f", location.x, location.y, translation.x, translation.y)
    }
    
    // ZLSwipeableViewDataSource
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView!) -> UIView! {
        let path:String = NSBundle.mainBundle().pathForResource("goog", ofType:"gif")! as NSString
        let data = NSData.dataWithContentsOfMappedFile(path) as NSData
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        
        let view = FLAnimatedImageView(frame: swipeableView.bounds)
        
        view.animatedImage = animatedImage
        view.contentMode = UIViewContentMode.ScaleAspectFit
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.33
        view.layer.shadowOffset = CGSizeMake(0, 1.5)
        view.layer.shadowRadius = 4.0
        view.layer.shouldRasterize = true
        
        // Corner Radius
        view.layer.cornerRadius = 10.0;
        
        return view
    }
}

