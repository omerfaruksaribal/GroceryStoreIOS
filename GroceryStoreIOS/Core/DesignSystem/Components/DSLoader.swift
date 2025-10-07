import UIKit

/// A minimal loading overlay (HUD) for blocking operations.
/// Shows a blur backdrop and a centered activity indicator with optional text.
public final class DSLoader: UIView {

    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let stack = UIStackView()
    private let indicator = UIActivityIndicatorView(style: .large)
    private let label = UILabel()

    public init(message: String? = nil) {
        super.init(frame: .zero)
        setup(message: message)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(message: nil)
    }

    private func setup(message: String?) {
        backgroundColor = UIColor.black.withAlphaComponent(0.1)

        addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DSSpacing.sm
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: DSSpacing.md, left: DSSpacing.lg, bottom: DSSpacing.md, right: DSSpacing.lg)

        let container = UIView()
        container.backgroundColor = DSColor.surfaceBase
        container.layer.cornerRadius = DSRadius.large
        container.layer.applyShadow(DSElevation.level2(for: traitCollection))

        container.addSubview(stack)
        addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        indicator.startAnimating()
        label.attributedText = NSAttributedString(
            string: message ?? "Loading…",
            attributes: DSFont.attributes(.subheadline, textColor: DSColor.textPrimary, alignment: .center)
        )

        stack.addArrangedSubview(indicator)
        stack.addArrangedSubview(label)
    }

    /// Adds loader to a view and fills its bounds.
    public func show(in view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Removes loader from superview.
    public func hide() {
        removeFromSuperview()
    }
}
