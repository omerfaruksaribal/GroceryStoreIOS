import UIKit

/// A reusable, theme-aware button with built-in states (loading/disabled)
/// and variants (primary, secondary, destructive, ghost, link).
public final class DSButton: UIButton {

    public enum Variant {
        case primary
        case secondary
        case destructive
        case ghost
        case link
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
    private var underlineLayer: CALayer?

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

        // Register for trait (light/dark) changes – iOS 17+
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: DSButton, previousStyle) in
                if self.variant == .link {
                    let color: UIColor = {
                        if self.traitCollection.userInterfaceStyle == .dark {
                            return UIColor(hex: "#E6EDF3")!
                        } else {
                            return UIColor(hex: "#1A1D2D")!
                        }
                    }()
                    self.underlineLayer?.backgroundColor = color.cgColor
                    self.setTitleColor(color, for: .normal)
                }
            }
        }
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

        // Remove previous underline if any
        underlineLayer?.removeFromSuperlayer()
        underlineLayer = nil

        // Special case: link variant
        if variant == .link {
            clipsToBounds = false
            layer.masksToBounds = false
            backgroundColor = .clear
            layer.borderWidth = 0
            layer.cornerRadius = 0

            let titleText = title(for: .normal) ?? ""
            // Use a dynamic, vivid accessible color for underline and text
            let underlineColor: UIColor = {
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(hex: "#E6EDF3")!
                } else {
                    return UIColor(hex: "#1A1D2D")!
                }
            }()

            // Underlined text (for accessibility + fallback)
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: underlineColor,
                .foregroundColor: underlineColor,
                .font: DSFont.font(.subheadline, weight: .semibold)
            ]
            let attrTitle = NSAttributedString(string: titleText, attributes: attributes)

            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.contentInsets = .zero
                config.baseForegroundColor = underlineColor
                config.attributedTitle = AttributedString(attrTitle)
                self.configuration = config
            } else {
                contentEdgeInsets = .zero
                setAttributedTitle(attrTitle, for: .normal)
            }
            setTitleColor(underlineColor, for: .normal)

            // Add visual underline layer (real line under text)
            let underline = CALayer()
            underline.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
            underline.shadowOpacity = 0.3
            underline.shadowOffset = .zero
            underline.shadowRadius = 0.5
            underline.backgroundColor = underlineColor.cgColor
            layer.addSublayer(underline)
            underlineLayer = underline

            // Compact sizing
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        // Disabled visuals
        if !isEnabled {
            backgroundColor = DSColor.disabledBackground
            setTitleColor(DSColor.textDisabled, for: .disabled)
        }
    }

    // MARK: - Visual style
    public override var isHighlighted: Bool {
        didSet {
            guard !isLoading else { return }
            if variant == .link {
                UIView.animate(withDuration: 0.15) {
                    self.underlineLayer?.opacity = self.isHighlighted ? 0.5 : 1.0
                }
                return
            }

            if isHighlighted {
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard variant == .link, let titleLabel, let underlineLayer else { return }

        let underlineHeight: CGFloat = 2.0
        let gap: CGFloat = 3.0

        // Position underline relative to the title label’s frame
        let underlineY = titleLabel.frame.maxY + gap
        underlineLayer.frame = CGRect(
            x: titleLabel.frame.minX,
            y: min(underlineY, bounds.height - underlineHeight - 1),
            width: titleLabel.intrinsicContentSize.width,
            height: underlineHeight
        )

        // Ensure it appears above other sublayers
        underlineLayer.zPosition = 10
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
        case .link:
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
        case .link:
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
