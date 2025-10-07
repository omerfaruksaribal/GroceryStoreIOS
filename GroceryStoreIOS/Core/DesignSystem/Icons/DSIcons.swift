import UIKit

/// Symbol catalog for icon usage. Map your semantic cases to SF Symbols here.
/// You can later swap any case to use a custom asset without changing call sites.
public enum DSIcon {
    case back
    case close
    case check
    case error
    case info
    case warning
    case email
    case password
    case user
    case cart
    case wishlist
    case orders
    case search
    case eye
    case eyeSlash
    case plus
    case minus

    /// Returns a configured UIImage for the requested point size and weight.
    public func image(pointSize: CGFloat = 18,
                      weight: UIImage.SymbolWeight = .regular,
                      scale: UIImage.SymbolScale = .medium) -> UIImage? {
        let name = symbolName
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
        return UIImage(systemName: name, withConfiguration: config)
    }

    /// Direct raw symbol name mapping (centralized).
    private var symbolName: String {
        switch self {
        case .back:      return "chevron.left"
        case .close:     return "xmark"
        case .check:     return "checkmark"
        case .error:     return "xmark.octagon.fill"
        case .info:      return "info.circle.fill"
        case .warning:   return "exclamationmark.triangle.fill"
        case .email:     return "envelope"
        case .password:  return "lock"
        case .user:      return "person"
        case .cart:      return "cart"
        case .wishlist:  return "heart"
        case .orders:    return "list.bullet.rectangle"
        case .search:    return "magnifyingglass"
        case .eye:       return "eye"
        case .eyeSlash:  return "eye.slash"
        case .plus:      return "plus"
        case .minus:     return "minus"
        }
    }
}
