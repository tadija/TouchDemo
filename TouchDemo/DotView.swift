//
//  DotView.swift
//  TouchDemo
//
//  Created by Marko Tadic on 9/11/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit

let kMinimumDotRadius: CGFloat = 30.0
let kMaximumDotRadius: CGFloat = 100.0

class DotView: UIView {

    // MARK: - Properties
    
    let color: UIColor?
    let radius: CGFloat?
    var highlighted: Bool? {
        willSet {
            if newValue == true {
                if let c = color {
                    backgroundColor = c.darkerColorWithFactor()
                }
            } else {
                if let c = color {
                    backgroundColor = c
                }
            }
        }
    }
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    init(color: UIColor, radius: CGFloat) {
        self.color = color
        self.radius = radius
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        backgroundColor = color
        layer.cornerRadius = radius / 2
    }
    
    convenience override init(frame: CGRect) {
        let randomColor = UIColor.randomVividColor()
        let randomRadius = DotView.randomValueFrom(Int(kMinimumDotRadius), to: Int(kMaximumDotRadius))
        self.init(color: randomColor!, radius: randomRadius)
    }
    
    class func randomValueFrom(_ fromValue: Int, to toValue: Int) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(toValue - fromValue)) + UInt32(fromValue))
    }
    
    // MARK: - Override
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = true
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = false
    }
    
    
    // enlarges hit area for very small dots
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var touchBounds = bounds
        if layer.cornerRadius < 22.0 {
            let expansion = 22.0 - layer.cornerRadius
            touchBounds = touchBounds.insetBy(dx: -expansion, dy: -expansion)
        }
        return touchBounds.contains(point)
    }
    
    // MARK: - Arrange Dots
    
    class func arrangeDotsRandomlyInView(_ containerView: UIView) {
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
    
    class func arrangeDotsNeatlyInView(_ containerView: UIView) {
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
    
    class func arrangeDotsNeatlyInViewWithNiftyAnimation(_ containerView: UIView) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            DotView.arrangeDotsNeatlyInView(containerView)
        })
    }

}
