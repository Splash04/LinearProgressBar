//
//  SwiftUIDemoScreen.swift
//  LinearProgressBar
//
//  Demos the pure SwiftUI `LinearProgressBarView` pinned under the
//  navigation bar. On iOS 26 the toolbar buttons and the liquid glass bar
//  both render with the native glass material.
//

import SwiftUI

struct SwiftUIDemoScreen: View {

    @State private var isAnimating = false
    @State private var useLiquidGlass = true
    @State private var useCapsuleLayout = true
    @State private var useClearGlass = false
    @State private var glowEnabled = true
    @State private var backdropEnabled = true

    private var style: LinearProgressBarStyle {
        guard useLiquidGlass else { return .flat }
        return .liquidGlass(LiquidGlassConfiguration(
            glassVariant: useClearGlass ? .clear : .regular,
            showsFrostedBackdrop: backdropEnabled,
            glow: glowEnabled ? LiquidGlassConfiguration.Glow() : nil,
            layout: useCapsuleLayout ? .floatingCapsule() : .edgeToEdge))
    }

    var body: some View {
        navigationContainer {
            content
                .safeAreaInset(edge: .top, spacing: 0) {
                    LinearProgressBarView(isAnimating: isAnimating, style: style)
                        .padding(.top, useLiquidGlass && useCapsuleLayout ? 6 : 0)
                }
                .navigationTitle("SwiftUI")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(isAnimating ? "Stop" : "Start") {
                            isAnimating.toggle()
                        }
                    }
                }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroCard
                controls
            }
            .padding()
        }
    }

    /// Vivid content near the top so the glass track has something to refract.
    private var heroCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(LinearGradient(colors: [.purple, .blue, .cyan, .mint],
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
            .frame(height: 140)
            .overlay(
                Text("Content behind the bar")
                    .font(.headline)
                    .foregroundColor(.white))
    }

    private var controls: some View {
        VStack(spacing: 0) {
            Toggle("Liquid Glass style", isOn: $useLiquidGlass)
                .padding(.vertical, 8)
            Group {
                Toggle("Floating capsule layout", isOn: $useCapsuleLayout)
                    .padding(.vertical, 8)
                Toggle("Clear glass variant", isOn: $useClearGlass)
                    .padding(.vertical, 8)
                Toggle("Indicator glow", isOn: $glowEnabled)
                    .padding(.vertical, 8)
                Toggle("Frosted track", isOn: $backdropEnabled)
                    .padding(.vertical, 8)
            }
            .disabled(!useLiquidGlass)
            .opacity(useLiquidGlass ? 1 : 0.4)
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    @ViewBuilder
    private func navigationContainer(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 16.0, *) {
            NavigationStack { content() }
        } else {
            NavigationView { content() }
                .navigationViewStyle(.stack)
        }
    }
}
