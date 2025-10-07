import UIKit

/// Design System spacing, radius, and elevation tokens.
/// Use these constants across all layout and view components
/// to ensure consistent spacing and corner behavior.
public enum DSSpacing {

    // MARK: - Spacing scale (4pt base grid)
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 40
}

public enum DSRadius {

    // MARK: - Corner radius values
    public static let none: CGFloat = 0
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
    public static let pill: CGFloat = 999  // for fully rounded buttons or avatars
}

public enum DSElevation {

    // MARK: - Shadow and elevation presets
    public static func level1(for trait: UITraitCollection) -> CALayer.ShadowProperties {
        return CALayer.ShadowProperties(
            color: DSColor.textPrimary.withAlphaComponent(0.08).cgColor,
            opacity: 1,
            offset: CGSize(width: 0, height: 1),
            radius: 3
        )
    }

    public static func level2(for trait: UITraitCollection) -> CALayer.ShadowProperties {
        return CALayer.ShadowProperties(
            color: DSColor.textPrimary.withAlphaComponent(0.12).cgColor,
            opacity: 1,
            offset: CGSize(width: 0, height: 4),
            radius: 6
        )
    }

    public static func none() -> CALayer.ShadowProperties {
        return CALayer.ShadowProperties(
            color: UIColor.clear.cgColor,
            opacity: 0,
            offset: .zero,
            radius: 0
        )
    }
}

/// A lightweight helper struct to encapsulate shadow configuration.
public extension CALayer {
    struct ShadowProperties {
        public let color: CGColor
        public let opacity: Float
        public let offset: CGSize
        public let radius: CGFloat
    }

    /// Applies a pre-defined shadow style.
    func applyShadow(_ properties: ShadowProperties) {
        shadowColor = properties.color
        shadowOpacity = properties.opacity
        shadowOffset = properties.offset
        shadowRadius = properties.radius
        masksToBounds = false
    }
}
