import UIKit

/// A reusable, theme-aware button with built-in states (loading/disabled)
/// and variants (primary, secondary, destructive, ghost).
public final class DSButton: UIButton {

    public enum Variant {
        case primary
        case secondary
        case destructive
        case ghost
    }

    public enum Size {
        case large
        case medium
        case small
    }

    // Public API
    public var isLoading: Bool = false {
        didSet { updateLoadingState() }
    }

    public var variant: Variant = .primary {
        didSet { applyStyle() }
    }

    public var size: Size = .medium {
        didSet { applySize() }
    }

    // Private UI
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var storedTitle: String?

    // Init
    public init(variant: Variant = .primary, size: Size = .medium) {
        self.variant = variant
        self.size = size
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        // Typography
        titleLabel?.font = DSFont.font(.headline, weight: .semibold)

        // Corner
        layer.cornerRadius = DSRadius.medium
        layer.masksToBounds = true

        // Activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isUserInteractionEnabled = false
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // Content paddings
        applySize()

        // Initial style
        applyStyle()
        updateLoadingState()
    }

    // MARK: - Layout presets

    private func applySize() {
        let insets: NSDirectionalEdgeInsets
        let font: UIFont

        switch size {
        case .large:
            insets = NSDirectionalEdgeInsets(top: DSSpacing.md, leading: DSSpacing.lg, bottom: DSSpacing.md, trailing: DSSpacing.lg)
            font = DSFont.font(.headline, weight: .semibold)
        case .medium:
            insets = NSDirectionalEdgeInsets(top: DSSpacing.sm, leading: DSSpacing.md, bottom: DSSpacing.sm, trailing: DSSpacing.md)
            font = DSFont.font(.headline, weight: .semibold)
        case .small:
            insets = NSDirectionalEdgeInsets(top: DSSpacing.xs, leading: DSSpacing.sm, bottom: DSSpacing.xs, trailing: DSSpacing.sm)
            font = DSFont.font(.subheadline, weight: .semibold)
        }

        if #available(iOS 15.0, *) {
            var config = self.configuration ?? UIButton.Configuration.filled()
            config.contentInsets = insets
            self.configuration = config
        } else {
            contentEdgeInsets = UIEdgeInsets(
                top: insets.top,
                left: insets.leading,
                bottom: insets.bottom,
                right: insets.trailing
            )
        }
        titleLabel?.font = font
    }

    // MARK: - Visual style

    public override var isHighlighted: Bool {
        didSet {
            guard !isLoading else { return }
            if isHighlighted {
                // Apply a subtle pressed overlay
                let overlay = DSColor.pressedOverlay(on: backgroundColor ?? .clear, trait: traitCollection)
                layer.backgroundColor = blend(base: effectiveBackgroundColor(), overlay: overlay).cgColor
            } else {
                layer.backgroundColor = effectiveBackgroundColor().cgColor
            }
        }
    }

    public override var isEnabled: Bool {
        didSet { applyStyle() }
    }

    private func applyStyle() {
        // Colors per variant
        let bg = effectiveBackgroundColor()
        let fg = effectiveTitleColor()

        backgroundColor = bg
        setTitleColor(fg, for: .normal)

        // Border for ghost
        if variant == .ghost {
            layer.borderWidth = 1
            layer.borderColor = DSColor.borderStrong.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }

        // Disabled visuals
        if !isEnabled {
            backgroundColor = DSColor.disabledBackground
            setTitleColor(DSColor.textDisabled, for: .disabled)
        }
    }

    private func effectiveBackgroundColor() -> UIColor {
        switch variant {
        case .primary:
            return isEnabled ? DSColor.primary : DSColor.disabledBackground
        case .secondary:
            return DSColor.surfaceElevated
        case .destructive:
            return isEnabled ? DSColor.statusError : DSColor.disabledBackground
        case .ghost:
            return .clear
        }
    }

    private func effectiveTitleColor() -> UIColor {
        switch variant {
        case .primary, .destructive:
            return DSColor.onPrimary
        case .secondary:
            return DSColor.textPrimary
        case .ghost:
            return DSColor.primary
        }
    }

    private func blend(base: UIColor, overlay: UIColor) -> UIColor {
        // Simple alpha blend for pressed state visuals
        let b = base.cgColor
        let o = overlay.cgColor

        guard
            let bc = b.components, let oc = o.components,
            b.numberOfComponents >= 3, o.numberOfComponents >= 3
        else { return base }

        let ba = b.alpha
        let oa = o.alpha

        let r = (oc[0] * oa) + (bc[0] * ba * (1 - oa))
        let g = (oc[1] * oa) + (bc[1] * ba * (1 - oa))
        let bl = (oc[2] * oa) + (bc[2] * ba * (1 - oa))
        let a = oa + ba * (1 - oa)
        return UIColor(red: r / a, green: g / a, blue: bl / a, alpha: 1.0)
    }

    // MARK: - Loading state

    private func updateLoadingState() {
        if isLoading {
            storedTitle = title(for: .normal)
            setTitle(nil, for: .normal)
            isUserInteractionEnabled = false
            activityIndicator.startAnimating()
        } else {
            if let t = storedTitle {
                setTitle(t, for: .normal)
            }
            isUserInteractionEnabled = isEnabled
            activityIndicator.stopAnimating()
        }
    }
}
