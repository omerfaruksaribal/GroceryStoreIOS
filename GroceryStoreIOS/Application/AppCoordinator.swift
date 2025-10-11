import UIKit

final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    /// Entry point for the app after launch
    func start() {
        if TokenStore.shared.isAuthenticated {
            showMainFlow()
        } else {
            showAuthFlow()
        }

        window.makeKeyAndVisible()
    }

    //  MARK: - Auth Flow
    private func showAuthFlow() {
        let loginVC = LoginVC()
        let nav = UINavigationController(rootViewController: loginVC)
        window.rootViewController = nav
    }

    //  MARK: - Main FLow
    private func showMainFlow() {
        let tabBar = MainTabBarController()
        window.rootViewController = tabBar
    }
}
