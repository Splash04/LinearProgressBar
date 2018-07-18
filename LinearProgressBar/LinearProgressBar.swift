//
//  LinearProgressBar.swift
//  CookMinute
//
//  Created by Philippe Boisney on 18/11/2015.
//  Copyright © 2015 CookMinute. All rights reserved.
//
//  Google Guidelines: https://www.google.com/design/spec/components/progress-activity.html#progress-activity-types-of-indicators
//

import UIKit

open class LinearProgressBar: UIView {
    
    //FOR DATA
    fileprivate var screenSize: CGRect = UIScreen.main.bounds
    fileprivate var isAnimationRunning = false
    
    //FOR DESIGN
    fileprivate var progressBarIndicator: UIView!
    
    //PUBLIC VARS
    open var backgroundProgressBarColor: UIColor = UIColor(red:0.73, green:0.87, blue:0.98, alpha:1.0)
    open var progressBarColor: UIColor = UIColor(red:0.12, green:0.53, blue:0.90, alpha:1.0)
    open var heightForLinearBar: CGFloat = 5
    open var widthForLinearBar: CGFloat = 0
    open var heightAnimationDuration: TimeInterval = 0.5
    open var progressAnimationDuration: TimeInterval = 1.0
    
    public init () {
        super.init(frame: CGRect(origin: CGPoint(x: 0,y :20), size: CGSize(width: screenSize.width, height: 0)))
        self.progressBarIndicator = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: heightForLinearBar)))
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.progressBarIndicator = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: heightForLinearBar)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: LIFE OF VIEW
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.screenSize = UIScreen.main.bounds
        
        if widthForLinearBar == 0 || widthForLinearBar == self.screenSize.height {
            widthForLinearBar = self.screenSize.width
        }
        
        if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
           self.frame = CGRect(origin: CGPoint(x: self.frame.origin.x,y :self.frame.origin.y), size: CGSize(width: widthForLinearBar, height: self.frame.height))
        }
        
        if (UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
            self.frame = CGRect(origin: CGPoint(x: self.frame.origin.x,y :self.frame.origin.y), size: CGSize(width: widthForLinearBar, height: self.frame.height))
        }
    }
    
    //MARK: PUBLIC FUNCTIONS    ------------------------------------------------------------------------------------------
    
    //Start the animation
    open func startAnimation(withDuration: TimeInterval? = nil) {
        let duration: TimeInterval = withDuration ?? self.heightAnimationDuration
        self.configureColors()
        
        self.show()
        
        if !isAnimationRunning {
            self.isAnimationRunning = true
            if duration > 0 {
                UIView.animate(withDuration: duration, delay:0, options: [], animations: {
                    self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.widthForLinearBar, height: self.heightForLinearBar)
                }, completion: { animationFinished in
                    self.addSubview(self.progressBarIndicator)
                    self.configureAnimation()
                })
            } else {
                self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.widthForLinearBar, height: self.heightForLinearBar)
                self.addSubview(self.progressBarIndicator)
                self.configureAnimation()
            }
        }
    }
    
    //Stop the animation
    open func stopAnimation(withDuration: TimeInterval? = nil) {
        let duration: TimeInterval = withDuration ?? self.heightAnimationDuration
        self.isAnimationRunning = false
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: {
                self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: self.widthForLinearBar, height: 0)
                self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.widthForLinearBar, height: 0)
            })
        } else {
            self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: self.widthForLinearBar, height: 0)
            self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.widthForLinearBar, height: 0)
        }
    }
    
    open func stopAnimationAfterCompletion() {
        self.isAnimationRunning = false
    }
    
    //MARK: PRIVATE FUNCTIONS    ------------------------------------------------------------------------------------------
    
    fileprivate func show() {
        
        // Only show once
        if self.superview != nil {
            return
        }
        
        // Find current top viewcontroller
        if let topController = getTopViewController() {
            let superView: UIView = topController.view
            superView.addSubview(self)
        }
    }
    
    fileprivate func configureColors() {
        
        self.backgroundColor = self.backgroundProgressBarColor
        self.progressBarIndicator.backgroundColor = self.progressBarColor
        self.layoutIfNeeded()
    }
    
    fileprivate func configureAnimation() {
        
        guard let superviewWidth = self.superview?.frame.width else {
            stopAnimation()
            return
        }

        self.progressBarIndicator.frame = CGRect(origin: CGPoint(x: 0, y :0), size: CGSize(width: 0, height: heightForLinearBar))
        let progressDuration = self.progressAnimationDuration
        UIView.animateKeyframes(withDuration: progressDuration, delay: 0, options: [], animations: { [weak self] in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: progressDuration / 2.0, animations: { [weak self] in
                guard let _self = self else { return }
                _self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: _self.widthForLinearBar * 0.7, height: _self.heightForLinearBar)
            })
            
            UIView.addKeyframe(withRelativeStartTime: progressDuration / 2.0, relativeDuration: progressDuration / 2.0, animations: { [weak self] in
                guard let _self = self else { return }
                _self.progressBarIndicator.frame = CGRect(x: superviewWidth, y: 0, width: 0, height: _self.heightForLinearBar)
            })
            
        }) { [weak self] (completed) in
            guard let _self = self else { return }
            if (_self.isAnimationRunning) {
                _self.configureAnimation()
            } else if _self.progressBarIndicator.frame.size.height >= _self.heightForLinearBar {
                _self.stopAnimation()
            }
        }
    }
    
    // -----------------------------------------------------
    //MARK: UTILS    ---------------------------------------
    // -----------------------------------------------------
    
    fileprivate func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
