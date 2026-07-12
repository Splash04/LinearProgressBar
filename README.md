# Linear Progress Bar (Material Design + Liquid Glass)

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

Indeterminate linear progress bar (inspired by [Google Material Design](https://www.google.com/design/spec/components/progress-activity.html#progress-activity-types-of-indicators#)) for iOS, written in Swift 6. Ships two implementations sharing one style system:

- `LinearProgressBar` — pure UIKit `UIView`
- `LinearProgressBarView` — pure SwiftUI `View` (iOS 15+)

Both support the classic **flat** Material style and an [iOS 26 **Liquid Glass**](https://developer.apple.com/documentation/technologyoverviews/liquid-glass) style: glass track, soft neon glow that travels with the indicator, and a spring materialize/dismiss animation. On iOS 26 the native glass APIs are used (`UIGlassEffect` / `.glassEffect`); older systems get a frosted-blur approximation.

Please feel free to make pull requests :)

![alt tag](https://github.com/PhilippeBoisney/LinearProgressBar/raw/master/demo.gif)

## INSTALLATION
#### Manually
Simply add the files from **Pod/Classes/** to your project.

#### CocoaPods
You can use [Cocoapods](http://cocoapods.org/) to install `Linear Progress Bar` by adding it to your `Podfile`:
```ruby
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
	pod 'LinearProgressBarMaterial'
end
```

#### [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

```ruby
https://github.com/Splash04/LinearProgressBar.git
```

## USAGE (UIKit)
```swift
//Simply, Call Progress Bar
let linearBar: LinearProgressBar = LinearProgressBar()

//Start Animation
self.linearBar.startAnimation()

//Stop Animation
self.linearBar.stopAnimation()
```
**OPTIONS**
```swift
//Change background color
linearBar.backgroundProgressBarColor = UIColor(red:0.68, green:0.81, blue:0.72, alpha:1.0)
linearBar.progressBarColor = UIColor(red:0.26, green:0.65, blue:0.45, alpha:1.0)

//Change height of progressBar
linearBar.heightForLinearBar = 5
```

## USAGE (Liquid Glass style)

Set `style` before starting (UIKit). The bar renders a glass capsule track,
a gradient "comet" indicator with a pulsing glow, and materializes in with a
spring instead of the classic height reveal:

```swift
linearBar.style = .liquidGlass                       // default configuration
linearBar.startAnimation()

// ...or configured:
linearBar.style = .liquidGlass(LiquidGlassConfiguration(
    glassVariant: .regular,                          // .clear for media-heavy backgrounds
    showsFrostedBackdrop: true,                      // the glass/frosted track
    glow: LiquidGlassConfiguration.Glow(radius: 8, opacity: 0.85, pulses: true),
    layout: .floatingCapsule(horizontalInset: 16)))  // or .edgeToEdge
```

Layouts: `.edgeToEdge` fits right under an opaque UIKit navigation bar;
`.floatingCapsule` matches iOS 26 floating glass navigation elements.

## USAGE (SwiftUI, iOS 15+)

`LinearProgressBarView` does not attach itself anywhere — place it yourself,
e.g. pinned under the navigation bar:

```swift
struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List { ... }
                .safeAreaInset(edge: .top, spacing: 0) {
                    LinearProgressBarView(isAnimating: isLoading,
                                          style: .liquidGlass)
                }
        }
    }
}
```

All init parameters: `isAnimating`, `style`, `barColor`, `trackColor`,
`height`, `progressAnimationDuration`.

## iOS version behavior

| | iOS 26+ | iOS 13–25 (UIKit) / 15–25 (SwiftUI) |
|---|---|---|
| `.flat` | classic Material bar | classic Material bar |
| `.liquidGlass` track | native glass (`UIGlassEffect` / `.glassEffect`) | frosted blur approximation |
| `.liquidGlass` appear/disappear | SwiftUI: native `.glassEffectTransition(.materialize)`; UIKit: spring | spring compress + fade |
| Indicator glow & comet gradient | ✓ | ✓ |

## FEATURES

- [x] Multi-Device Full Support
- [x] Rotation Support
- [x] Material Design Effect
- [x] iOS 26 Liquid Glass style (glass track, neon glow, materialize animation)
- [x] Pure SwiftUI implementation
- [x] Swift 6 support (strict concurrency)

## Version
1.4


## Author

Philippe BOISNEY (phil.boisney(@)gmail.com)
