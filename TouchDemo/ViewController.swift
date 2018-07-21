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
        case .phone:
            return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) ? width : height / 1.4
        default:
            return height / 1.9
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let bounds = self.view.bounds
        
        canvasView = UIView(frame: bounds)
        canvasView.backgroundColor = UIColor.darkGray
        view.addSubview(canvasView)
        
        scrollView = OverlayScrollView(frame: bounds)
        view.addSubview(scrollView)
        
        drawerView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        scrollView.addSubview(drawerView)
		
		if #available(iOS 11.0, *) {
			scrollView.contentInsetAdjustmentBehavior = .never
		} else {
			// Fallback on earlier versions
			self.automaticallyAdjustsScrollViewInsets = false
		}
		
        let device = view.traitCollection.userInterfaceIdiom
        addDots(device == .pad ? 25 : 10, toView: canvasView)
        addDots(device == .pad ? 20 : 7, toView: drawerView.contentView)
        arrangeDotsAndDrawerWithinSize(bounds.size)
        
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
    
    func addDots(_ count: Int, toView view: UIView) {
        for _ in 1...count {
            let dot = DotView()
            view.addSubview(dot)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
            longPress.cancelsTouchesInView = false
            longPress.delegate = self
            dot.addGestureRecognizer(longPress)
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let views: [String : UIView] = ["canvasView" : canvasView, "scrollView" : scrollView]
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[canvasView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[canvasView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.arrangeDotsAndDrawerWithinSize(size)
        }, completion: nil)
    }
    
    func arrangeDotsAndDrawerWithinSize(_ size: CGSize) {
        // set drawer size
        drawerView.frame = CGRect(x: 0, y: 0, width: size.width, height: drawerHeight)
        scrollView.contentSize = CGSize(width: size.width, height: size.height + drawerView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: 0, y: drawerView.frame.size.height)
        
        // arrange dots
        DotView.arrangeDotsRandomlyInView(canvasView)
        DotView.arrangeDotsNeatlyInView(drawerView.contentView)
    }
    
    // MARK: - Gestures
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if let dot = gesture.view {
            switch gesture.state {
            case .began:
                grabDot(dot, withGesture: gesture)
            case .changed:
                moveDot(dot, withGesture: gesture)
            case .ended, .cancelled:
                dropDot(dot, withGesture: gesture)
            default:
                print("gesture state not implemented")
            }
        }
    }
    
    func grabDot(_ dot: UIView, withGesture gesture: UIGestureRecognizer) {
        let dotFromDrawer = dot.superview === drawerView.contentView
        
        dot.center = view.convert(dot.center, from: dot.superview)
        view.addSubview(dot)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            dot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            dot.alpha = 0.8
            self.moveDot(dot, withGesture: gesture)
        })
        
        // disable and re-enable scrollview's pan gesture recognizer so the drawer can't be opened with moving the dot view
        // disabling will cause it to stop tracking all the touches which it was tracking (including the long press)
        // re-enabling will allow it to be ready to track new touches that might start
        scrollView.panGestureRecognizer.isEnabled = false;
        scrollView.panGestureRecognizer.isEnabled = true;
        
        if dotFromDrawer {
            DotView.arrangeDotsNeatlyInViewWithNiftyAnimation(drawerView.contentView)
        }
    }
    
    func moveDot(_ dot: UIView, withGesture gesture: UIGestureRecognizer) {
        dot.center = gesture.location(in: view)
    }
    
    func dropDot(_ dot: UIView, withGesture gesture: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            dot.transform = CGAffineTransform.identity
            dot.alpha = 1.0
        })
        
        let locationInDrawer = gesture.location(in: drawerView)
        if drawerView.bounds.contains(locationInDrawer) {
            drawerView.contentView.addSubview(dot)
        } else {
            canvasView.addSubview(dot)
        }
        dot.center = view.convert(dot.center, to: dot.superview)
        
        if dot.superview === drawerView.contentView {
            DotView.arrangeDotsNeatlyInViewWithNiftyAnimation(drawerView.contentView)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // we should be specific here because it's easy source of bugs
        // but in this example we do want that all of the gestures (long press, pan, indicator) to work simultaneously
        // so it's possible to move the dots with multiple fingers, and open drawer with other finger at the same time
        return true
    }

}

