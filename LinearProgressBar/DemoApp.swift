//
//  DemoApp.swift
//  LinearProgressBar
//
//  Pure SwiftUI demo app: one SwiftUI screen and one code-only UIKit screen.
//

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            SwiftUIDemoScreen()
                .tabItem { Label("SwiftUI", systemImage: "swift") }
            UIKitDemoScreen()
                .ignoresSafeArea()
                .tabItem { Label("UIKit", systemImage: "square.stack.3d.up") }
        }
    }
}
