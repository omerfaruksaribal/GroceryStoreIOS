import UIKit

/// Theme variant selection. `system` follows the user's iOS setting.
public enum DSThemeVariant: Equatable {
    case system
    case light
    case dark
}

/// A small theme container to keep non-color tokens that might vary per theme.
/// Colors are already dynamic in DSColor; here you can override brand accents,
/// corner radii, or component-level tweaks if needed in the future.
public struct DSTheme {
    public let variant: DSThemeVariant

    /// Example: override default corner radii per theme if desired.
    public let defaultCornerRadius: CGFloat

    /// Example: brand tint used for selection/highlights.
    public let brandTint: UIColor

    public init(
        variant: DSThemeVariant,
        defaultCornerRadius: CGFloat = DSRadius.medium,
        brandTint: UIColor? = nil
    ) {
        self.variant = variant
        self.defaultCornerRadius = defaultCornerRadius
        self.brandTint = brandTint ?? DSColor.primary
    }
}
