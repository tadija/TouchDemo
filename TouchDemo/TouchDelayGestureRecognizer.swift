//
//  TouchDelayGestureRecognizer.swift
//  TouchDemo
//
//  This gesture recognizer will delay touches to it's view,
//  so if for example some pan gesture recognizes the pan is happening,
//  the other possible gestures (like tap) will not fire.
//
//  Created by Marko Tadic on 9/12/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDelayGestureRecognizer: UIGestureRecognizer {
    
    // MARK: - Properties
    
    var timer: NSTimer?
    
    // MARK: - Init
    
    override init(target: AnyObject, action: Selector) {
        super.init(target: target, action: action)
        delaysTouchesBegan = true
    }
    
    // MARK: - Override
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: Selector("fail"), userInfo: nil, repeats: false)
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        fail()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        fail()
    }
    
    func fail() {
        state = .Failed
    }
    
    override func reset() {
        timer?.invalidate()
        timer = nil
    }
    
}
