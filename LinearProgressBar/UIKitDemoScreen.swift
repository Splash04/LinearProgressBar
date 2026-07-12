//
//  UIKitDemoScreen.swift
//  LinearProgressBar
//
//  Demos the UIKit `LinearProgressBar` inside a fully programmatic
//  `UINavigationController` (no storyboards). The bar is placed right under
//  the navigation bar, the library's primary use case.
//

import SwiftUI
import UIKit

struct UIKitDemoScreen: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: UIKitDemoViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

final class UIKitDemoViewController: UIViewController {

    private let progressBar = LinearProgressBar()
    private var isAnimating = false

    private let liquidGlassSwitch = UISwitch()
    private let capsuleLayoutSwitch = UISwitch()
    private let clearGlassSwitch = UISwitch()
    private let glowSwitch = UISwitch()
    private let frostedTrackSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleAnimation))
        liquidGlassSwitch.isOn = true
        capsuleLayoutSwitch.isOn = true
        glowSwitch.isOn = true
        frostedTrackSwitch.isOn = true
        buildContent()
    }

    private var currentStyle: LinearProgressBarStyle {
        guard liquidGlassSwitch.isOn else { return .flat }
        return .liquidGlass(LiquidGlassConfiguration(
            glassVariant: clearGlassSwitch.isOn ? .clear : .regular,
            showsFrostedBackdrop: frostedTrackSwitch.isOn,
            glow: glowSwitch.isOn ? LiquidGlassConfiguration.Glow() : nil,
            layout: capsuleLayoutSwitch.isOn ? .floatingCapsule() : .edgeToEdge))
    }

    @objc private func toggleAnimation() {
        if isAnimating {
            progressBar.stopAnimation()
        } else {
            // Configure before starting, like any consumer of the library.
            progressBar.style = currentStyle
            if progressBar.superview == nil {
                view.addSubview(progressBar)
            }
            let capsuleGap: CGFloat = capsuleLayoutSwitch.isOn && liquidGlassSwitch.isOn ? 6 : 0
            progressBar.frame.origin.y = view.safeAreaInsets.top + capsuleGap
            progressBar.startAnimation()
        }
        isAnimating.toggle()
        navigationItem.rightBarButtonItem?.title = isAnimating ? "Stop" : "Start"
    }

    // MARK: - Static demo content (programmatic UI)

    private func buildContent() {
        let heroCard = GradientCardView()
        heroCard.layer.cornerRadius = 20
        heroCard.clipsToBounds = true
        heroCard.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let heroLabel = UILabel()
        heroLabel.text = "Content behind the bar"
        heroLabel.font = .preferredFont(forTextStyle: .headline)
        heroLabel.textColor = .white
        heroLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroLabel)
        NSLayoutConstraint.activate([
            heroLabel.centerXAnchor.constraint(equalTo: heroCard.centerXAnchor),
            heroLabel.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor)
        ])

        let controlsStack = UIStackView(arrangedSubviews: [
            switchRow(title: "Liquid Glass style", control: liquidGlassSwitch),
            switchRow(title: "Floating capsule layout", control: capsuleLayoutSwitch),
            switchRow(title: "Clear glass variant", control: clearGlassSwitch),
            switchRow(title: "Indicator glow", control: glowSwitch),
            switchRow(title: "Frosted track", control: frostedTrackSwitch)
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.isLayoutMarginsRelativeArrangement = true
        controlsStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let controlsCard = UIView()
        controlsCard.backgroundColor = .secondarySystemBackground
        controlsCard.layer.cornerRadius = 16
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsCard.addSubview(controlsStack)
        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: controlsCard.topAnchor),
            controlsStack.bottomAnchor.constraint(equalTo: controlsCard.bottomAnchor),
            controlsStack.leadingAnchor.constraint(equalTo: controlsCard.leadingAnchor),
            controlsStack.trailingAnchor.constraint(equalTo: controlsCard.trailingAnchor)
        ])

        let noteLabel = UILabel()
        noteLabel.text = "Style changes apply on the next start."
        noteLabel.font = .preferredFont(forTextStyle: .footnote)
        noteLabel.textColor = .secondaryLabel
        noteLabel.textAlignment = .center

        let mainStack = UIStackView(arrangedSubviews: [heroCard, controlsCard, noteLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func switchRow(title: String, control: UISwitch) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .body)
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }
}

/// Vivid gradient card so the glass track has something to refract.
private final class GradientCardView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let gradient = layer as! CAGradientLayer
        gradient.colors = [UIColor.systemPurple.cgColor,
                           UIColor.systemBlue.cgColor,
                           UIColor.systemCyan.cgColor,
                           UIColor.systemMint.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
