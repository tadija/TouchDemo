//
//  OverlayScrollView.swift
//  TouchDemo
//
//  This subclass will not return self from the hit testing, if the hit is on self.
//  This will allow the touch to pass through self and go on to other siblings of self if there are any.
//
//  Created by Marko Tadic on 9/12/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit

class OverlayScrollView: UIScrollView {

    // MARK: - Override
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        }
        
        return hitView
    }

}
