//
//  LinearProgressBar.swift
//  CookMinute
//
//  Created by Philippe Boisney on 18/11/2015.
//  Copyright © 2015 CookMinute. All rights reserved.
//
//  Google Guidelines: https://www.google.com/design/spec/components/progress-activity.html#progress-activity-types-of-indicators
//  Liquid Glass: https://developer.apple.com/documentation/technologyoverviews/liquid-glass
//

import UIKit

open class LinearProgressBar: UIView {

    //FOR DATA
    fileprivate var screenSize: CGRect = UIScreen.main.bounds
    fileprivate var isAnimationRunning = false

    //FOR DESIGN
    fileprivate var progressBarIndicator: IndicatorView!
    fileprivate var trackEffectView: UIVisualEffectView?

    //PUBLIC VARS
    open var backgroundProgressBarColor: UIColor = UIColor(red:0.73, green:0.87, blue:0.98, alpha:1.0)
    open var progressBarColor: UIColor = UIColor(red:0.12, green:0.53, blue:0.90, alpha:1.0)
    open var heightForLinearBar: CGFloat = 5
    open var widthForLinearBar: CGFloat = 0
    open var heightAnimationDuration: TimeInterval = 0.5
    open var progressAnimationDuration: TimeInterval = 1.0
    /// Visual style. Set before calling `startAnimation()`.
    /// `.flat` (default) keeps the classic Material bar; `.liquidGlass`
    /// enables the iOS 26 glass track, indicator glow and spring
    /// materialize/dismiss animations (frosted approximation before iOS 26).
    open var style: LinearProgressBarStyle = .flat

    public init () {
        super.init(frame: CGRect(origin: CGPoint(x: 0,y :20), size: CGSize(width: screenSize.width, height: 0)))
        self.progressBarIndicator = IndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: heightForLinearBar)))
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.progressBarIndicator = IndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: heightForLinearBar)))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: LIFE OF VIEW
    override open func layoutSubviews() {
        super.layoutSubviews()

        if widthForLinearBar == 0 || widthForLinearBar == self.screenSize.height {
            widthForLinearBar = self.screenSize.width
        }

        if case .liquidGlass(let configuration) = style {
            if UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isPortrait {
                self.frame = barFrame(for: configuration, height: self.frame.height)
            }
            trackEffectView?.frame = self.bounds
            return
        }

        if UIDevice.current.orientation.isLandscape {
           self.frame = CGRect(origin: CGPoint(x: self.frame.origin.x,y :self.frame.origin.y), size: CGSize(width: widthForLinearBar, height: self.frame.height))
        }

        if UIDevice.current.orientation.isPortrait {
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

            if case .liquidGlass(let configuration) = style {
                startLiquidGlassAppearance(configuration: configuration, duration: duration)
                return
            }

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

        if case .liquidGlass = style {
            stopLiquidGlassAppearance(duration: duration)
            return
        }

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

        switch style {
        case .flat:
            self.backgroundColor = self.backgroundProgressBarColor
            self.progressBarIndicator.configureFlat(color: self.progressBarColor)
        case .liquidGlass(let configuration):
            self.backgroundColor = .clear
            self.progressBarIndicator.configureLiquidGlass(color: self.progressBarColor,
                                                           glow: configuration.glow,
                                                           cornerRadius: self.heightForLinearBar / 2)
            configureTrack(for: configuration)
        }
        self.layoutIfNeeded()
    }

    fileprivate func configureAnimation() {

        guard let superviewWidth = self.superview?.frame.width else {
            stopAnimation()
            return
        }

        // In the liquid glass style the indicator sweeps the bar's own bounds
        // (the bar may be an inset capsule); the flat style keeps its historic
        // superview-width-based sweep.
        var sweepWidth = self.widthForLinearBar
        var exitX = superviewWidth
        if case .liquidGlass = style {
            sweepWidth = self.bounds.width
            exitX = self.bounds.width
        }

        self.progressBarIndicator.frame = CGRect(origin: CGPoint(x: 0, y :0), size: CGSize(width: 0, height: heightForLinearBar))
        let progressDuration = self.progressAnimationDuration
        UIView.animateKeyframes(withDuration: progressDuration, delay: 0, options: [], animations: { [weak self] in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: progressDuration / 2.0, animations: { [weak self] in
                guard let _self = self else { return }
                _self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: sweepWidth * 0.7, height: _self.heightForLinearBar)
            })

            UIView.addKeyframe(withRelativeStartTime: progressDuration / 2.0, relativeDuration: progressDuration / 2.0, animations: { [weak self] in
                guard let _self = self else { return }
                _self.progressBarIndicator.frame = CGRect(x: exitX, y: 0, width: 0, height: _self.heightForLinearBar)
            })

        }) { [weak self] (completed) in
            // UIView animation completion handlers are always invoked on the main thread.
            MainActor.assumeIsolated {
                guard let _self = self else { return }
                if (_self.isAnimationRunning) {
                    _self.configureAnimation()
                } else if _self.progressBarIndicator.frame.size.height >= _self.heightForLinearBar {
                    _self.stopAnimation()
                }
            }
        }
    }

    // -----------------------------------------------------
    //MARK: LIQUID GLASS    --------------------------------
    // -----------------------------------------------------

    fileprivate func barFrame(for configuration: LiquidGlassConfiguration, height: CGFloat) -> CGRect {
        let availableWidth = self.superview?.bounds.width ?? widthForLinearBar
        switch configuration.layout {
        case .edgeToEdge:
            return CGRect(x: 0, y: self.frame.origin.y, width: availableWidth, height: height)
        case .floatingCapsule(let horizontalInset):
            return CGRect(x: horizontalInset,
                          y: self.frame.origin.y,
                          width: availableWidth - horizontalInset * 2,
                          height: height)
        }
    }

    fileprivate func configureTrack(for configuration: LiquidGlassConfiguration) {
        guard configuration.showsFrostedBackdrop else {
            trackEffectView?.removeFromSuperview()
            trackEffectView = nil
            return
        }

        let effectView: UIVisualEffectView
        if let existing = trackEffectView {
            effectView = existing
        } else {
            effectView = UIVisualEffectView()
            effectView.isUserInteractionEnabled = false
            insertSubview(effectView, at: 0)
            trackEffectView = effectView
        }
        effectView.frame = self.bounds

        let isCapsule: Bool
        if case .floatingCapsule = configuration.layout {
            isCapsule = true
        } else {
            isCapsule = false
        }

        if #available(iOS 26.0, *) {
            let glass: UIGlassEffect
            switch configuration.glassVariant {
            case .regular: glass = UIGlassEffect(style: .regular)
            case .clear: glass = UIGlassEffect(style: .clear)
            }
            glass.tintColor = backgroundProgressBarColor.withAlphaComponent(0.25)
            effectView.effect = glass
            effectView.cornerConfiguration = isCapsule ? .capsule() : .uniformCorners(radius: .fixed(0))
        } else {
            configureLegacyFrostedTrack(effectView, isCapsule: isCapsule)
        }
    }

    fileprivate func startLiquidGlassAppearance(configuration: LiquidGlassConfiguration, duration: TimeInterval) {
        self.frame = barFrame(for: configuration, height: heightForLinearBar)
        trackEffectView?.frame = self.bounds
        self.progressBarIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: heightForLinearBar))
        self.addSubview(self.progressBarIndicator)
        self.progressBarIndicator.startGlowPulseIfNeeded(glow: configuration.glow)

        guard duration > 0 else {
            self.configureAnimation()
            return
        }

        // Materialize: condense in from a slightly compressed, transparent state.
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.96, y: 0.4)
            .concatenating(CGAffineTransform(translationX: 0, y: -heightForLinearBar * 0.4))
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.72,
                       initialSpringVelocity: 0.4,
                       options: [.allowUserInteraction],
                       animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: { _ in
            self.configureAnimation()
        })
    }

    fileprivate func stopLiquidGlassAppearance(duration: TimeInterval) {
        self.progressBarIndicator.stopGlowPulse()

        let finalize = {
            self.transform = .identity
            self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: self.heightForLinearBar)
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: 0)
            self.alpha = 1
        }

        guard duration > 0 else {
            self.alpha = 0
            finalize()
            return
        }

        // Dismiss: dissolve out with a gentle vertical compression.
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.6)
        }, completion: { _ in
            // Completion runs on the main thread.
            MainActor.assumeIsolated {
                finalize()
            }
        })
    }

    // MARK: - Legacy fallback (< iOS 26) — delete when the minimum target is iOS 26

    fileprivate func configureLegacyFrostedTrack(_ effectView: UIVisualEffectView, isCapsule: Bool) {
        effectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        effectView.clipsToBounds = true
        effectView.layer.cornerRadius = isCapsule ? heightForLinearBar / 2 : 0
        effectView.contentView.backgroundColor = backgroundProgressBarColor.withAlphaComponent(0.15)

        let hairlineTag = 987_001
        if effectView.contentView.viewWithTag(hairlineTag) == nil {
            // Cheap "glass edge" illusion: a translucent hairline along the top.
            let hairline = UIView(frame: CGRect(x: 0, y: 0, width: effectView.bounds.width, height: 0.5))
            hairline.tag = hairlineTag
            hairline.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            hairline.autoresizingMask = [.flexibleWidth]
            effectView.contentView.addSubview(hairline)
        }
    }

    // -----------------------------------------------------
    //MARK: UTILS    ---------------------------------------
    // -----------------------------------------------------

    fileprivate func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.firstKeyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}

// -----------------------------------------------------
//MARK: INDICATOR    -----------------------------------
// -----------------------------------------------------

/// The moving element of the bar. Flat style paints a plain color; liquid
/// glass style paints a "comet" gradient and carries a soft neon glow.
///
/// The gradient is the view's OWN backing layer: a gradient hosted in a
/// subview would not track the keyframe frame animation (subview layout
/// resolves to the final model value, not the interpolated one).
fileprivate final class IndicatorView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    private static let pulseAnimationKey = "linearProgressBar.glowPulse"

    func configureFlat(color: UIColor) {
        gradientLayer.colors = nil
        backgroundColor = color
        layer.shadowOpacity = 0
        stopGlowPulse()
    }

    func configureLiquidGlass(color: UIColor, glow: LiquidGlassConfiguration.Glow?, cornerRadius: CGFloat) {
        backgroundColor = .clear
        // masksToBounds must stay false so the glow shadow can escape;
        // at a ~5pt bar height the missing corner clip is imperceptible.
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            color.withAlphaComponent(0).cgColor,
            color.cgColor,
            color.brightened(by: 0.25).cgColor
        ]
        gradientLayer.locations = [0, 0.55, 1]

        if let glow {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = Float(glow.opacity)
            layer.shadowRadius = glow.radius
            layer.shadowOffset = .zero
        } else {
            layer.shadowOpacity = 0
        }
    }

    func startGlowPulseIfNeeded(glow: LiquidGlassConfiguration.Glow?) {
        stopGlowPulse()
        guard let glow, glow.pulses else { return }
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = glow.radius
        pulse.toValue = glow.radius * 1.4
        pulse.duration = 1.2
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: Self.pulseAnimationKey)
    }

    func stopGlowPulse() {
        layer.removeAnimation(forKey: Self.pulseAnimationKey)
    }
}

fileprivate extension UIColor {
    /// Returns the color blended toward white by `fraction` (0...1).
    func brightened(by fraction: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return self }
        return UIColor(red: red + (1 - red) * fraction,
                       green: green + (1 - green) * fraction,
                       blue: blue + (1 - blue) * fraction,
                       alpha: alpha)
    }
}

fileprivate extension UIApplication {

    /// Returns the first key window across all connected scenes
    var firstKeyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return connectedScenes
                .compactMap {
                    ($0 as? UIWindowScene)?.keyWindow
                }
                .first

        } else {
            return connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        }
    }
}
