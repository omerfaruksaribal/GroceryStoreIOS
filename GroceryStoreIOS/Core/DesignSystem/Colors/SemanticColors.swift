import UIKit

/// Opacity tokens for interaction layers.
enum DSOpacity {
    static let pressedLightOverlay: CGFloat = 0.10   // black on light
    static let pressedDarkOverlay: CGFloat  = 0.14   // white on dark
    static let primaryPressedOverlay: CGFloat = 0.12 // inner overlay feeling
    static let selectedLight: CGFloat = 0.12
    static let selectedDark: CGFloat  = 0.24
}

/// Semantic, role-based colors used across UI.
/// All colors are dynamic and adapt to userInterfaceStyle.
enum DSColor {

    // MARK: - Background & Surfaces
    static var background: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? ColorPalette.darkBg
            : ColorPalette.neutral50
        }
    }

    static var surfaceBase: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? ColorPalette.darkSurfaceBase
            : ColorPalette.neutral0
        }
    }

    static var surfaceElevated: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? ColorPalette.darkSurfaceElev
            : ColorPalette.neutral100
        }
    }

    static var surfaceMuted: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? ColorPalette.darkSurfaceMuted
            : ColorPalette.neutral200
        }
    }

    // MARK: - Primary / Secondary
    static var primary: UIColor { ColorPalette.brandPrimary }
    static var onPrimary: UIColor { .white }

    static var secondary: UIColor { ColorPalette.accentSecondary }
    static var onSecondary: UIColor { UIColor(hex: "#1B1B1B")! }

    // MARK: - Text
    static var textPrimary: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.neutral0 : ColorPalette.neutral900
        }
    }

    static var textSecondary: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.neutral400 : ColorPalette.neutral700
        }
    }

    static var textDisabled: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.neutral600 : ColorPalette.neutral500
        }
    }

    static var onSurface: UIColor { textPrimary }

    // MARK: - Borders & Divider
    static var borderStrong: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.darkBorderStrong : ColorPalette.neutral300
        }
    }

    static var borderSoft: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.darkBorderSoft : ColorPalette.neutral200
        }
    }

    static var divider: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.darkDivider : ColorPalette.neutral200
        }
    }

    // MARK: - Status / Feedback
    static var statusSuccess: UIColor { ColorPalette.success }
    static var statusError: UIColor   { ColorPalette.error }
    static var statusWarning: UIColor { ColorPalette.warning }
    static var statusInfo: UIColor    { ColorPalette.info }
    static var onStatus: UIColor { .white } // Consider dark text on warning bg depending on usage.

    // MARK: - Focus ring
    static var focusRing: UIColor { ColorPalette.accentTertiary }

    // MARK: - Interaction helpers

    /// Pressed overlay for surfaces (adds subtle shadow/ink effect).
    static func pressedOverlay(on color: UIColor, trait: UITraitCollection) -> UIColor {
        if color == DSColor.primary {
            // Overlay on primary surfaces (same hue, slight darkening)
            return ColorPalette.black.withAlpha(DSOpacity.primaryPressedOverlay)
        }
        // On light surfaces: black overlay; on dark: white overlay
        return (trait.userInterfaceStyle == .dark ? UIColor.white : ColorPalette.black)
            .withAlpha(trait.userInterfaceStyle == .dark ? DSOpacity.pressedDarkOverlay
                                                         : DSOpacity.pressedLightOverlay)
    }

    /// Selected background for chips/toggles derived from primary.
    static func selectedBackground(trait: UITraitCollection) -> UIColor {
        DSColor.primary.withAlpha(trait.userInterfaceStyle == .dark ? DSOpacity.selectedDark
                                                                    : DSOpacity.selectedLight)
    }

    /// Disabled background color for controls.
    static var disabledBackground: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? ColorPalette.darkDivider : ColorPalette.neutral200
        }
    }
}
