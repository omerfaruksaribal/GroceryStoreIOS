import UIKit

/// Raw brand/neutral palette (no semantics here).
enum ColorPalette {
    // Brand & Accents
    static let brandPrimary       = UIColor(hex: "#2E7D32")!   // rich green
    static let brandPrimarySoft   = UIColor(hex: "#43A047")!
    static let accentSecondary    = UIColor(hex: "#FFC107")!   // amber
    static let accentTertiary     = UIColor(hex: "#00ACC1")!   // cyan

    // Feedback
    static let success            = UIColor(hex: "#2E7D32")!
    static let error              = UIColor(hex: "#D32F2F")!
    static let warning            = UIColor(hex: "#F57C00")!
    static let info               = UIColor(hex: "#1976D2")!

    // Neutrals
    static let neutral0           = UIColor(hex: "#FFFFFF")!
    static let neutral50          = UIColor(hex: "#FAFAFA")!
    static let neutral100         = UIColor(hex: "#F5F5F5")!
    static let neutral200         = UIColor(hex: "#EEEEEE")!
    static let neutral300         = UIColor(hex: "#E0E0E0")!
    static let neutral400         = UIColor(hex: "#BDBDBD")!
    static let neutral500         = UIColor(hex: "#9E9E9E")!
    static let neutral600         = UIColor(hex: "#757575")!
    static let neutral700         = UIColor(hex: "#616161")!
    static let neutral800         = UIColor(hex: "#424242")!
    static let neutral900         = UIColor(hex: "#212121")!
    static let black              = UIColor(hex: "#000000")!

    // Dark-mode surfaces (custom tuned)
    static let darkBg             = UIColor(hex: "#0E0F10")!
    static let darkSurfaceBase    = UIColor(hex: "#151618")!
    static let darkSurfaceElev    = UIColor(hex: "#1C1E21")!
    static let darkSurfaceMuted   = UIColor(hex: "#222529")!
    static let darkBorderStrong   = UIColor(hex: "#2B2E33")!
    static let darkBorderSoft     = UIColor(hex: "#232529")!
    static let darkDivider        = UIColor(hex: "#2A2C31")!
}
