import UIKit

/// Root tab bar for the authenticated user.
final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.background
        setupTabs()
    }

    private func setupTabs() {
        let home = UINavigationController(rootViewController: UIViewController())
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let cart = UINavigationController(rootViewController: UIViewController())
        cart.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)

        let profile = UINavigationController(rootViewController: UIViewController())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

        viewControllers = [home, cart, profile]
    }
}
