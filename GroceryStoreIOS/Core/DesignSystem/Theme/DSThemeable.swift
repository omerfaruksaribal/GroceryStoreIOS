import UIKit

/// Conform views or controllers to be automatically informed on theme changes.
public protocol DSThemeable: AnyObject {
    func applyTheme(_ theme: DSTheme)
}

public extension DSThemeable where Self: UIViewController {
    func startObservingThemeChanges() {
        NotificationCenter.default.addObserver(
            forName: .DSThemeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let theme = note.object as? DSTheme else { return }
            self?.applyTheme(theme)
        }
        // Apply current theme immediately
        applyTheme(DSThemeManager.shared.theme)
    }

    func stopObservingThemeChanges() {
        NotificationCenter.default.removeObserver(self, name: .DSThemeDidChange, object: nil)
    }
}

public extension DSThemeable where Self: UIView {
    func startObservingThemeChanges() {
        NotificationCenter.default.addObserver(
            forName: .DSThemeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let theme = note.object as? DSTheme else { return }
            self?.applyTheme(theme)
        }
        // Apply current theme immediately
        applyTheme(DSThemeManager.shared.theme)
    }

    func stopObservingThemeChanges() {
        NotificationCenter.default.removeObserver(self, name: .DSThemeDidChange, object: nil)
    }
}
