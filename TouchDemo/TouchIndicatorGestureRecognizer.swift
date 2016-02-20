//
//  TouchIndicatorGestureRecognizer.swift
//  TouchDemo
//
//  This gesture recognizer will show indicators for every touch, which will follow touch movement.
//  It supports multitouch, and it's possible to show custom indicator view by overriding indicator() func.
//
//  Created by Marko Tadic on 9/12/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchIndicatorGestureRecognizer: UIGestureRecognizer {
    
    // MARK: - Properties
    
    var activeTouches = [UITouch: UIView]()
    
    // MARK: - Init
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
    }
    
    // MARK: - Override
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            createIndicatorView(touch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        for touch in touches {
            moveIndicatorView(touch)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            removeIndicatorView(touch)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        for touch in touches{
            removeIndicatorView(touch)
        }
    }
    
    // MARK: - Indicator
    
    class func indicator() -> UIView {
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        indicator.backgroundColor = UIColor.whiteColor()
        indicator.alpha = 0.8
        indicator.layer.cornerRadius = 10.0
        return indicator
    }
    
    func createIndicatorView(touch: UITouch) {
        state = .Began
        
        let indicator = TouchIndicatorGestureRecognizer.indicator()
        indicator.center = touch.locationInView(view)
        indicator.transform = CGAffineTransformMakeScale(0.01, 0.01)
        indicator.layer.zPosition = CGFloat(MAXFLOAT);
        
        if let gestureView = view {
            gestureView.addSubview(indicator)
            activeTouches[touch] = indicator
        }
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { () -> Void in
            indicator.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    func moveIndicatorView(touch: UITouch) {
        if let indicator = activeTouches[touch] {
            indicator.center = touch.locationInView(view)
            state = .Changed
        }
    }
    
    func removeIndicatorView(touch: UITouch) {
        if let indicator = activeTouches[touch] {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: { () -> Void in
                indicator.transform = CGAffineTransformMakeScale(0.01, 0.01)
                }, completion: { (finished) -> Void in
                    indicator.removeFromSuperview()
                    self.activeTouches.removeValueForKey(touch)
                    if self.activeTouches.count == 0 {
                        self.state = .Ended
                    }
            })
        }
    }

}
