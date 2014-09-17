//
//  ViewController.swift
//  TouchDemo
//
//  Created by Marko Tadic on 9/11/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var canvasView: UIView!
    var scrollView: UIScrollView!
    var drawerView: UIVisualEffectView!
    
    var drawerHeight: CGFloat {
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        switch view.traitCollection.userInterfaceIdiom {
        case .Phone:
            return UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) ? width : height / 1.4
        default:
            return height / 1.9
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let bounds = self.view.bounds
        
        canvasView = UIView(frame: bounds)
        canvasView.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(canvasView)
        
        scrollView = OverlayScrollView(frame: bounds)
        view.addSubview(scrollView)
        
        drawerView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        scrollView.addSubview(drawerView)

        let device = view.traitCollection.userInterfaceIdiom
        addDots(device == .Pad ? 25 : 10, toView: canvasView)
        addDots(device == .Pad ? 20 : 7, toView: drawerView.contentView)
        self.arrangeDotsAndDrawerWithinSize(bounds.size)
        
        // move scrollview's gesture recognizer to the superview
        // because of the override in the OverlayScrollView (it's not hit testing, so gesture will not work)
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        // disable highlighting dot views when starting to pan from the dot view
        let touchDelay = TouchDelayGestureRecognizer(target: self, action: nil)
        canvasView.addGestureRecognizer(touchDelay)
        
        // show touch indicator view which follows touch movement
        let touchIndicator = TouchIndicatorGestureRecognizer(target: self, action: nil)
        touchIndicator.delegate = self
        view.addGestureRecognizer(touchIndicator)
    }
    
    func addDots(count: Int, toView view: UIView) {
        for i in 1...count {
            let dot = DotView()
            view.addSubview(dot)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
            longPress.cancelsTouchesInView = false
            longPress.delegate = self
            dot.addGestureRecognizer(longPress)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let views = ["canvasView" : canvasView, "scrollView" : scrollView]
        for (name, view) in views {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[canvasView]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[canvasView]|", options: nil, metrics: nil, views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: views))
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.arrangeDotsAndDrawerWithinSize(size)
        }, completion: nil)
    }
    
    func arrangeDotsAndDrawerWithinSize(size: CGSize) {
        // set drawer size
        drawerView.frame = CGRect(x: 0, y: 0, width: size.width, height: drawerHeight)
        scrollView.contentSize = CGSize(width: size.width, height: size.height + drawerView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: 0, y: drawerView.frame.size.height)
        
        // arrange dots
        DotView.arrangeDotsRandomlyInView(canvasView)
        DotView.arrangeDotsNeatlyInView(drawerView.contentView)
    }
    
    // MARK: - Gestures
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if let dot = gesture.view {
            switch gesture.state {
            case .Began:
                grabDot(dot, withGesture: gesture)
            case .Changed:
                moveDot(dot, withGesture: gesture)
            case .Ended, .Cancelled:
                dropDot(dot, withGesture: gesture)
            default:
                println("gesture state not implemented")
            }
        }
    }
    
    func grabDot(dot: UIView, withGesture gesture: UIGestureRecognizer) {
        let dotFromDrawer = dot.superview === drawerView.contentView
        
        dot.center = view.convertPoint(dot.center, fromView: dot.superview)
        view.addSubview(dot)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            dot.transform = CGAffineTransformMakeScale(1.2, 1.2)
            dot.alpha = 0.8
            self.moveDot(dot, withGesture: gesture)
        })
        
        // disable and re-enable scrollview's pan gesture recognizer so the drawer can't be opened with moving the dot view
        // disabling will cause it to stop tracking all the touches which it was tracking (including the long press)
        // re-enabling will allow it to be ready to track new touches that might start
        scrollView.panGestureRecognizer.enabled = false;
        scrollView.panGestureRecognizer.enabled = true;
        
        if dotFromDrawer {
            DotView.arrangeDotsNeatlyInViewWithNiftyAnimation(drawerView.contentView)
        }
    }
    
    func moveDot(dot: UIView, withGesture gesture: UIGestureRecognizer) {
        dot.center = gesture.locationInView(view)
    }
    
    func dropDot(dot: UIView, withGesture gesture: UIGestureRecognizer) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            dot.transform = CGAffineTransformIdentity
            dot.alpha = 1.0
        })
        
        let locationInDrawer = gesture.locationInView(drawerView)
        if CGRectContainsPoint(drawerView.bounds, locationInDrawer) {
            drawerView.contentView.addSubview(dot)
        } else {
            canvasView.addSubview(dot)
        }
        dot.center = view.convertPoint(dot.center, toView: dot.superview)
        
        if dot.superview === drawerView.contentView {
            DotView.arrangeDotsNeatlyInViewWithNiftyAnimation(drawerView.contentView)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // we should be specific here because it's easy source of bugs
        // but in this example we do want that all of the gestures (long press, pan, indicator) to work simultaneously
        // so it's possible to move the dots with multiple fingers, and open drawer with other finger at the same time
        return true
    }

}

