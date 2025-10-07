import UIKit

/// Notification fired when theme changes.
public extension Notification.Name {
    static let DSThemeDidChange = Notification.Name("DSThemeDidChange")
}

/// A lightweight theme manager. It controls the UI style (light/dark/system),
/// publishes changes, and can apply theme to a given window.
public final class DSThemeManager {

    public static let shared = DSThemeManager()

    private init() {}

    public private(set) var theme: DSTheme = DSTheme(variant: .system)

    /// Apply a theme variant and optionally to a specific UIWindow.
    /// - Parameters:
    ///   - variant: Desired theme variant.
    ///   - window: If provided, `overrideUserInterfaceStyle` is applied.
    public func apply(
        variant: DSThemeVariant,
        to window: UIWindow? = nil
    ) {
        theme = DSTheme(variant: variant)

        // Apply interface style to the window if provided
        if let win = window {
            switch variant {
            case .system:
                win.overrideUserInterfaceStyle = .unspecified
            case .light:
                win.overrideUserInterfaceStyle = .light
            case .dark:
                win.overrideUserInterfaceStyle = .dark
            }
        }

        // Optionally customize global appearances here (buttons, navbars, etc.)
        applyGlobalAppearances()

        // Broadcast change
        NotificationCenter.default.post(name: .DSThemeDidChange, object: theme)
    }

    /// Central place to tweak UIAppearance proxies if needed.
    private func applyGlobalAppearances() {
        // Example: UINavigationBar appearance
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = DSColor.surfaceBase
        nav.titleTextAttributes = [
            .font: DSFont.font(.headline, weight: .semibold),
            .foregroundColor: DSColor.textPrimary
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = DSColor.primary

        // Example: UIButton appearance (only affect .system where appropriate)
        UIButton.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = DSColor.primary
    }
}
