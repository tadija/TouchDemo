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
    
    var activeTouches = [UITouch : UIView]()
    
    // MARK: - Init
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
    }
    
    // MARK: - Override
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            createIndicatorView(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            moveIndicatorView(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            removeIndicatorView(touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        for touch in touches{
            removeIndicatorView(touch)
        }
    }
    
    // MARK: - Indicator
    
    class func indicator() -> UIView {
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        indicator.backgroundColor = UIColor.white
        indicator.alpha = 0.8
        indicator.layer.cornerRadius = 10.0
        return indicator
    }
    
    func createIndicatorView(_ touch: UITouch) {
        state = .began
        
        let indicator = TouchIndicatorGestureRecognizer.indicator()
        indicator.center = touch.location(in: view)
        indicator.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        indicator.layer.zPosition = CGFloat(MAXFLOAT);
        
        if let gestureView = view {
            gestureView.addSubview(indicator)
            activeTouches[touch] = indicator
        }
        
        UIView.animate(withDuration: 0.2, delay: 0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                       options: .allowUserInteraction, animations: { () -> Void in
            indicator.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func moveIndicatorView(_ touch: UITouch) {
        if let indicator = activeTouches[touch] {
            indicator.center = touch.location(in: view)
            state = .changed
        }
    }
    
    func removeIndicatorView(_ touch: UITouch) {
        if let indicator = activeTouches[touch] {
            UIView.animate(withDuration: 0.2, delay: 0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                           options: .allowUserInteraction, animations: { () -> Void in
                indicator.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished) -> Void in
                indicator.removeFromSuperview()
                self.activeTouches.removeValue(forKey: touch)
                if self.activeTouches.count == 0 {
                    self.state = .ended
                }
            })
        }
    }

}
