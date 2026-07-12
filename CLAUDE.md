# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`LinearProgressBarMaterial` is a tiny iOS Swift library rendering a Material-Design-style indeterminate linear progress bar, with an opt-in iOS 26 Liquid Glass style. It ships two implementations sharing one style system:

- `LinearProgressBar` — pure UIKit `UIView` subclass (`Pod/Classes/LinearProgressBar.swift`)
- `LinearProgressBarView` — pure SwiftUI view, `@available(iOS 15, *)` (`Pod/Classes/LinearProgressBarView.swift`)
- `LinearProgressBarStyle` / `LiquidGlassConfiguration` — shared `Sendable` style types (`Pod/Classes/LinearProgressBarStyle.swift`)

The repo contains the library plus a pure-SwiftUI demo app that exercises both implementations.

## Repository layout — single shared source

All library sources live only in `Pod/Classes/`. They are the source for CocoaPods (`LinearProgressBarMaterial.podspec`, glob `Pod/Classes/**/*`), Swift Package Manager (`Package.swift`, target path `Pod`), and the demo app target: `LinearProgressBar.xcodeproj`'s "Lib" group holds file *references* into `Pod/Classes/` (`sourceTree = SOURCE_ROOT`) rather than copies, so editing those files updates every distribution channel. **When adding a library file, add it under `Pod/Classes/` AND add a SOURCE_ROOT file reference to the demo project** (use the `xcodeproj` Ruby gem rather than hand-editing the pbxproj). `PrivacyInfo.xcprivacy` exists only in `Pod/` — a CocoaPods/SPM resource, not used by the demo.

- `LinearProgressBar/` — demo app target, pure SwiftUI, no storyboards/AppDelegate: `DemoApp.swift` (`@main`, TabView), `SwiftUIDemoScreen.swift` (NavigationStack + `LinearProgressBarView` via `.safeAreaInset(edge: .top)`), `UIKitDemoScreen.swift` (code-built `UINavigationController` in a `UIViewControllerRepresentable` demoing the UIKit bar), `Assets.xcassets`, `Info.plist` (`UILaunchScreen = {}`). Deployment target iOS 15.
- `Pod/` — the distributable library package contents (what SPM/CocoaPods consumers actually pull in).
- `LinearProgressBarMaterial.podspec` — CocoaPods spec (iOS 13, `swift_version 6.0`); bump `s.version` here when releasing.
- `Package.swift` — SPM manifest; `swift-tools-version:6.0`, iOS 13+ deployment target, Swift 6 language mode.

## Building / running

This is an Xcode project with no CLI test suite or lint config. Everything compiles in Swift 6 language mode (strict concurrency).

- Open `LinearProgressBar.xcodeproj` in Xcode and run the `LinearProgressBar` scheme on a simulator to see the demo app (two tabs: SwiftUI and UIKit, each with start/stop + style toggles).
- Build from the command line: `xcodebuild -project LinearProgressBar.xcodeproj -scheme LinearProgressBar -sdk iphonesimulator build`
- There are no unit tests in this repo.
- To validate the podspec: `pod lib lint LinearProgressBarMaterial.podspec`

## Library architecture notes

- Style system: `LinearProgressBarStyle` is `.flat` (default — the historical Material bar, behavior intentionally unchanged) or `.liquidGlass(LiquidGlassConfiguration)` (glass track, gradient "comet" indicator with glow, spring materialize/dismiss). Config knobs: `glassVariant` (.regular/.clear), `showsFrostedBackdrop`, `glow` (radius/opacity/pulses, nil = off), `layout` (`.edgeToEdge` or `.floatingCapsule(horizontalInset:)`).
- **iOS 26-first convention**: on iOS 26 only native APIs are used — `UIGlassEffect` + `cornerConfiguration` (UIKit), `.glassEffect`/`.glassEffectTransition(.materialize)` (SwiftUI). Pre-26 fallbacks (ultra-thin-material blur + hairline, compress/fade transitions, `AnyShapeCompat`) live in sections marked `Legacy fallback (< iOS 26) — delete when the minimum target is iOS 26` and must stay deletable in one pass. Don't blend native and legacy code paths.
- UIKit `LinearProgressBar` inserts itself into the view hierarchy on `startAnimation()` by walking up from `UIApplication`'s key window to the topmost presented view controller (`getTopViewController()`) — callers can also add it manually first (`show()` is a no-op if it has a superview).
- Flat animation: a height "reveal" (`heightAnimationDuration`), then a repeating two-keyframe sweep of `progressBarIndicator` (`progressAnimationDuration`), driven recursively via `configureAnimation()` completion handlers while `isAnimationRunning` is true. Liquid glass replaces only the appear/dismiss (spring transform + alpha); the sweep loop is shared (sweeps `bounds.width` in glass mode, historical superview-width in flat).
- **Keyframe-animation trap**: the indicator's comet gradient is the view's own backing layer (`layerClass = CAGradientLayer` on `IndicatorView`). Do NOT move it into a subview — a subview's layout resolves to the final model frame during `UIView.animateKeyframes`, so it renders at width 0 for the whole sweep. Same reason the glow is `layer.shadow*` on that view, with `masksToBounds` left false.
- SwiftUI `LinearProgressBarView` does not auto-attach; callers place it (typically `.safeAreaInset(edge: .top)`). The sweep is `TimelineView(.animation)`-driven from `appearedAt`, mirroring the UIKit keyframe math (grow to 70% for the first half-phase, slide out for the second).
- Public configuration surface is set via `open var` properties (UIKit) before calling `startAnimation()` / via init parameters (SwiftUI), not mutated mid-animation; style changes apply on the next start.
- Orientation/width changes are handled in `layoutSubviews()`.
