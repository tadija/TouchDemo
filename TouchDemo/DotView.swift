//
//  DotView.swift
//  TouchDemo
//
//  Created by Marko Tadic on 9/11/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit

let kMinimumDotRadius: CGFloat = 30.0;
let kMaximumDotRadius: CGFloat = 100.0;

class DotView: UIView {

    // MARK: - Properties
    
    let color: UIColor?
    let radius: CGFloat?
    var highlighted: Bool? {
        willSet {
            if newValue == true {
                backgroundColor = color?.darkerColorWithFactor()
            } else {
                backgroundColor = color
            }
        }
    }
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(color: UIColor, radius: CGFloat) {
        self.color = color
        self.radius = radius
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        backgroundColor = color
        layer.cornerRadius = radius / 2
    }
    
    convenience override init() {
        let randomColor = UIColor.randomVividColor()
        let randomRadius = DotView.randomValueFrom(Int(kMinimumDotRadius), to: Int(kMaximumDotRadius))
        self.init(color: randomColor, radius: randomRadius)
    }
    
    class func randomValueFrom(fromValue: Int, to toValue: Int) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(toValue - fromValue)) + fromValue)
    }
    
    // MARK: - Override
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        highlighted = true
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        highlighted = false
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        highlighted = false
    }
    
    // enlarges hit area for very small dots
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var touchBounds = bounds
        if layer.cornerRadius < 22.0 {
            let expansion = 22.0 - layer.cornerRadius
            touchBounds = CGRectInset(touchBounds, -expansion, -expansion)
        }
        return CGRectContainsPoint(touchBounds, point)
    }
    
    // MARK: - Arrange Dots
    
    class func arrangeDotsRandomlyInView(containerView: UIView) {
        let size = containerView.bounds.size
        for view in containerView.subviews {
            if let dot = view as? DotView {
                let dotDiameter: CGFloat = dot.layer.cornerRadius * 2
                let randomX = DotView.randomValueFrom(Int(dotDiameter), to: Int(size.width - dotDiameter))
                let randomY = DotView.randomValueFrom(Int(dotDiameter), to: Int(size.height - dotDiameter))
                dot.center = CGPoint(x: randomX, y: randomY)
            }
        }
    }
    
    class func arrangeDotsNeatlyInView(containerView: UIView) {
        let width: CGFloat = containerView.bounds.size.width
        let neatFactor: CGFloat = width < 600.0 ? 0 : width < 1024.0 ? 1 : 2;
        
        let horizontalSlotCount = floor(width / kMaximumDotRadius) - neatFactor
        let totalSlotSpacing = width - (horizontalSlotCount * kMaximumDotRadius)
        let slotSpacing = totalSlotSpacing / horizontalSlotCount
        
        let dotSlotSide = kMaximumDotRadius + slotSpacing
        let halfDotSlotSide = dotSlotSide / 2.0
        
        var initialX = halfDotSlotSide
        var initialY = halfDotSlotSide
        
        for view in containerView.subviews {
            if let dot = view as? DotView {
                let neatX = initialX
                let neatY = initialY
                dot.center = CGPoint(x: neatX, y: neatY)
                
                initialX = initialX + dotSlotSide
                if initialX >= containerView.bounds.size.width {
                    initialX = halfDotSlotSide
                    initialY = initialY + dotSlotSide
                }
            }
        }
    }
    
    class func arrangeDotsNeatlyInViewWithNiftyAnimation(containerView: UIView) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            DotView.arrangeDotsNeatlyInView(containerView)
        })
    }

}
