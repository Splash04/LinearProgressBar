//
//  LinearProgressBarStyle.swift
//  LinearProgressBarMaterial
//
//  Shared style configuration for the UIKit (`LinearProgressBar`) and
//  SwiftUI (`LinearProgressBarView`) implementations.
//

import UIKit

/// Visual style of the progress bar.
public enum LinearProgressBarStyle: Equatable, Sendable {

    /// The classic flat Material-Design bar. Default; behavior is identical
    /// to versions of the library that predate styles.
    case flat

    /// iOS 26 Liquid-Glass-inspired bar: glass track, soft neon glow on the
    /// moving indicator and a spring materialize/dismiss animation.
    /// On systems older than iOS 26 a frosted-blur approximation is used.
    case liquidGlass(LiquidGlassConfiguration)

    /// `liquidGlass` with the default configuration.
    public static var liquidGlass: LinearProgressBarStyle { .liquidGlass(LiquidGlassConfiguration()) }
}

/// Configuration of the `liquidGlass` style.
public struct LiquidGlassConfiguration: Equatable, Sendable {

    /// Which glass material variant the track uses on iOS 26.
    public enum GlassVariant: Equatable, Sendable {
        /// Standard glass. Best general-purpose choice.
        case regular
        /// Clear glass; more transparent, suited to media-heavy backgrounds.
        case clear
    }

    /// Horizontal geometry of the bar.
    public enum Layout: Equatable, Sendable {
        /// Full-width strip (the classic geometry) — fits right under an
        /// opaque UIKit navigation bar.
        case edgeToEdge
        /// Inset capsule that visually matches iOS 26 floating navigation
        /// elements. Recommended with SwiftUI Liquid Glass navigation.
        case floatingCapsule(horizontalInset: CGFloat = 16)
    }

    /// Soft neon glow that travels with the indicator.
    public struct Glow: Equatable, Sendable {
        /// Blur radius of the glow.
        public var radius: CGFloat
        /// Peak opacity of the glow.
        public var opacity: CGFloat
        /// When `true` the glow slowly pulses while the bar animates.
        public var pulses: Bool

        public init(radius: CGFloat = 8, opacity: CGFloat = 0.85, pulses: Bool = true) {
            self.radius = radius
            self.opacity = opacity
            self.pulses = pulses
        }
    }

    /// Glass material variant used on iOS 26.
    public var glassVariant: GlassVariant
    /// Shows the glass/frosted track behind the indicator. When `false` only
    /// the indicator (and its glow) is visible.
    public var showsFrostedBackdrop: Bool
    /// Indicator glow; `nil` disables it.
    public var glow: Glow?
    /// Horizontal geometry of the bar.
    public var layout: Layout

    public init(glassVariant: GlassVariant = .regular,
                showsFrostedBackdrop: Bool = true,
                glow: Glow? = Glow(),
                layout: Layout = .edgeToEdge) {
        self.glassVariant = glassVariant
        self.showsFrostedBackdrop = showsFrostedBackdrop
        self.glow = glow
        self.layout = layout
    }
}
