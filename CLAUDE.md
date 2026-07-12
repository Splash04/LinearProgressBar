# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`LinearProgressBarMaterial` is a tiny iOS Swift library: a single `UIView` subclass (`LinearProgressBar`) that renders a Material-Design-style indeterminate linear progress bar. The repo contains the library itself plus a demo app that exercises it.

## Repository layout — single shared source file

There is only one copy of `LinearProgressBar.swift`, at `Pod/Classes/LinearProgressBar.swift`. It is the source for CocoaPods (referenced by `LinearProgressBarMaterial.podspec`), Swift Package Manager (referenced by `Package.swift`, target path `Pod`), and the demo app target: `LinearProgressBar.xcodeproj`'s "Lib" group holds a file *reference* to `Pod/Classes/LinearProgressBar.swift` (`sourceTree = SOURCE_ROOT`) rather than its own copy, so editing that one file updates every distribution channel. `PrivacyInfo.xcprivacy` exists only in `Pod/` — it's a CocoaPods/SPM resource for the distributed library and isn't needed by (or referenced from) the demo app target.

- `LinearProgressBar/` — demo app target: `AppDelegate.swift`, `ViewController.swift` (wires up start/stop buttons to a `LinearProgressBar` instance), storyboards, assets. No longer contains its own `LinearProgressBar.swift` or `PrivacyInfo.xcprivacy`.
- `Pod/` — the distributable library package contents (what SPM/CocoaPods consumers actually pull in), and the only copy of `LinearProgressBar.swift` and `PrivacyInfo.xcprivacy`.
- `LinearProgressBarMaterial.podspec` — CocoaPods spec; bump `s.version` here when releasing.
- `Package.swift` — SPM manifest; `swift-tools-version:6.0`, iOS 13+ deployment target, Swift 6 language mode.

## Building / running

This is an Xcode project with no CLI test suite or lint config.

- Open `LinearProgressBar.xcodeproj` in Xcode and run the `LinearProgressBar` scheme on a simulator to see the demo app (two buttons: start/stop animation).
- Build from the command line: `xcodebuild -project LinearProgressBar.xcodeproj -scheme LinearProgressBar -sdk iphonesimulator build`
- There are no unit tests in this repo.
- To validate the podspec: `pod lib lint LinearProgressBarMaterial.podspec`

## Library architecture notes

- `LinearProgressBar` inserts itself into the view hierarchy on `startAnimation()` by walking up from `UIApplication`'s key window to the topmost presented view controller (`getTopViewController()`) and adding itself as a subview there — callers don't need to add it manually.
- Animation has two phases: a height "reveal" animation (`heightAnimationDuration`), then a repeating keyframe animation of the inner `progressBarIndicator` bar sliding across (`progressAnimationDuration`), driven recursively via `configureAnimation()` completion handlers while `isAnimationRunning` is true.
- Public configuration surface (colors, height, width, durations) is set via `open var` properties before calling `startAnimation()`, not via an initializer.
- Orientation/width changes are handled in `layoutSubviews()`.
