//
//  LinearProgressBarView.swift
//  LinearProgressBarMaterial
//
//  Pure SwiftUI implementation of the indeterminate linear progress bar.
//  Unlike the UIKit `LinearProgressBar`, this view does not attach itself to
//  the view hierarchy — place it yourself, e.g. via
//  `.safeAreaInset(edge: .top) { LinearProgressBarView(isAnimating: loading) }`.
//

import SwiftUI

@available(iOS 15.0, *)
public struct LinearProgressBarView: View {

    private let isAnimating: Bool
    private let style: LinearProgressBarStyle
    private let barColor: Color
    private let trackColor: Color
    private let height: CGFloat
    private let progressAnimationDuration: TimeInterval

    @State private var appearedAt: Date = .distantPast

    public init(isAnimating: Bool,
                style: LinearProgressBarStyle = .flat,
                barColor: Color = Color(red: 0.12, green: 0.53, blue: 0.90),
                trackColor: Color = Color(red: 0.73, green: 0.87, blue: 0.98),
                height: CGFloat = 5,
                progressAnimationDuration: TimeInterval = 1.0) {
        self.isAnimating = isAnimating
        self.style = style
        self.barColor = barColor
        self.trackColor = trackColor
        self.height = height
        self.progressAnimationDuration = progressAnimationDuration
    }

    public var body: some View {
        ZStack {
            if isAnimating {
                bar
                    .transition(appearTransition)
                    .onAppear { appearedAt = Date() }
            }
        }
        .animation(appearAnimation, value: isAnimating)
    }

    // MARK: - Bar composition

    private var bar: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                ZStack(alignment: .leading) {
                    track
                    indicator(totalWidth: geometry.size.width, date: context.date)
                }
            }
        }
        .frame(height: height)
        .padding(.horizontal, horizontalInset)
    }

    @ViewBuilder
    private var track: some View {
        switch style {
        case .flat:
            Rectangle().fill(trackColor)
        case .liquidGlass(let configuration):
            if configuration.showsFrostedBackdrop {
                if #available(iOS 26.0, *) {
                    glassTrack(configuration)
                } else {
                    legacyFrostedTrack(configuration)
                }
            }
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func glassTrack(_ configuration: LiquidGlassConfiguration) -> some View {
        let glass: Glass = {
            switch configuration.glassVariant {
            case .regular: return .regular.tint(trackColor.opacity(0.25))
            case .clear: return .clear.tint(trackColor.opacity(0.25))
            }
        }()
        if isCapsule {
            Color.clear
                .glassEffect(glass, in: Capsule())
                .glassEffectTransition(.materialize)
        } else {
            Color.clear
                .glassEffect(glass, in: Rectangle())
                .glassEffectTransition(.materialize)
        }
    }

    // MARK: Legacy fallback (< iOS 26) — delete when the minimum target is iOS 26

    @ViewBuilder
    private func legacyFrostedTrack(_ configuration: LiquidGlassConfiguration) -> some View {
        let shape = isCapsule ? AnyShapeCompat(Capsule()) : AnyShapeCompat(Rectangle())
        shape
            .fill(.ultraThinMaterial)
            .overlay(shape.fill(trackColor.opacity(0.15)))
            .overlay(alignment: .top) {
                // Cheap "glass edge" illusion: a translucent hairline along the top.
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 0.5)
            }
            .clipShape(shape)
    }

    private func indicator(totalWidth: CGFloat, date: Date) -> some View {
        let sweep = sweepMetrics(totalWidth: totalWidth, date: date)
        return indicatorShape
            .frame(width: sweep.width, height: height)
            .offset(x: sweep.x)
            .shadow(color: glowColor, radius: glowRadius(date: date))
    }

    @ViewBuilder
    private var indicatorShape: some View {
        switch style {
        case .flat:
            Rectangle().fill(barColor)
        case .liquidGlass:
            // "Comet": transparent tail -> bar color -> brightened head.
            Capsule().fill(LinearGradient(
                stops: [
                    .init(color: barColor.opacity(0), location: 0),
                    .init(color: barColor, location: 0.55),
                    .init(color: brightenedBarColor, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing))
        }
    }

    // MARK: - Sweep (matches the UIKit two-keyframe animation)

    private func sweepMetrics(totalWidth: CGFloat, date: Date) -> (x: CGFloat, width: CGFloat) {
        let elapsed = date.timeIntervalSince(appearedAt)
        guard progressAnimationDuration > 0, elapsed > 0 else { return (0, 0) }
        let phase = CGFloat((elapsed / progressAnimationDuration)
            .truncatingRemainder(dividingBy: 1))
        if phase < 0.5 {
            // Grow from the leading edge to 70% of the track.
            return (0, totalWidth * 0.7 * (phase / 0.5))
        } else {
            // Slide out while shrinking.
            let u = (phase - 0.5) / 0.5
            return (totalWidth * u, totalWidth * 0.7 * (1 - u))
        }
    }

    // MARK: - Glow

    private var glow: LiquidGlassConfiguration.Glow? {
        guard case .liquidGlass(let configuration) = style else { return nil }
        return configuration.glow
    }

    private var glowColor: Color {
        guard let glow else { return .clear }
        return barColor.opacity(glow.opacity)
    }

    private func glowRadius(date: Date) -> CGFloat {
        guard let glow else { return 0 }
        guard glow.pulses else { return glow.radius }
        // Slow sine pulse between 1x and 1.4x radius.
        let t = date.timeIntervalSince(appearedAt)
        let wave = 0.5 + 0.5 * sin(t * .pi * 2 / 2.4)
        return glow.radius * (1 + 0.4 * wave)
    }

    // MARK: - Layout / transitions

    private var isCapsule: Bool {
        if case .liquidGlass(let configuration) = style,
           case .floatingCapsule = configuration.layout {
            return true
        }
        return false
    }

    private var horizontalInset: CGFloat {
        if case .liquidGlass(let configuration) = style,
           case .floatingCapsule(let inset) = configuration.layout {
            return inset
        }
        return 0
    }

    private var appearAnimation: Animation {
        switch style {
        case .flat:
            return .easeInOut(duration: 0.5)
        case .liquidGlass:
            return .spring(response: 0.45, dampingFraction: 0.75)
        }
    }

    private var appearTransition: AnyTransition {
        switch style {
        case .flat:
            // Approximates the classic height-reveal.
            return .verticalCompress(from: 0.01)
        case .liquidGlass:
            if #available(iOS 26.0, *) {
                // The glass track materializes natively (`glassEffectTransition`);
                // the indicator just fades along.
                return .opacity
            }
            // MARK: Legacy fallback (< iOS 26) — delete when the minimum target is iOS 26
            return .verticalCompress(from: 0.4).combined(with: .opacity)
        }
    }

    private var brightenedBarColor: Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(barColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return barColor }
        let fraction: CGFloat = 0.25
        return Color(red: red + (1 - red) * fraction,
                     green: green + (1 - green) * fraction,
                     blue: blue + (1 - blue) * fraction,
                     opacity: alpha)
    }
}

/// `AnyShape` exists only from iOS 16 — minimal type-erased shape for iOS 15.
/// Delete together with the legacy (< iOS 26) fallbacks.
@available(iOS 15.0, *)
private struct AnyShapeCompat: Shape {
    private let makePath: @Sendable (CGRect) -> Path
    init(_ shape: some Shape) {
        let sendableShape = UncheckedSendableBox(value: shape)
        makePath = { rect in sendableShape.value.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path { makePath(rect) }
}

private struct UncheckedSendableBox<T>: @unchecked Sendable { let value: T }

@available(iOS 15.0, *)
private struct VerticalCompressModifier: ViewModifier {
    let scale: CGFloat
    func body(content: Content) -> some View {
        content.scaleEffect(x: 1, y: scale, anchor: .top)
    }
}

@available(iOS 15.0, *)
private extension AnyTransition {
    /// Compresses the view vertically toward its top edge.
    static func verticalCompress(from scale: CGFloat) -> AnyTransition {
        .modifier(active: VerticalCompressModifier(scale: scale),
                  identity: VerticalCompressModifier(scale: 1))
    }
}
