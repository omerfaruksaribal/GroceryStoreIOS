import UIKit

public enum DSTextStyle: CaseIterable {
    case display       // headers - biggest one
    case title1
    case title2
    case headline
    case body
    case subheadline
    case caption
    case footnote
}

/// you can change the nil to the custom font what would you like to use
/// if it stay as nil, iOS will be use default fonts
public struct DSFontConfig {
    public static var customFontNameRegular: String? = nil   // ex. "Poppins-Regular"
    public static var customFontNameBold: String? = nil      // ex. "Poppins-SemiBold"
    public static var customFontNameMedium: String? = nil    // ex. "Poppins-Medium"
}

/// Design System Typography API
public enum DSFont {

    /// Text style → (basic point size, default weight, line height).
    private static func descriptor(for style: DSTextStyle) -> (baseSize: CGFloat,
                                                            weight: UIFont.Weight,
                                                            lineHeight:CGFloat,
                                                            letterSpacing: CGFloat) {
        switch style {
        case .display: return (34, .bold, 42, 0.0)
        case .title1: return (28, .bold, 34, 0.0)
        case .title2: return (22, .semibold, 28, 0.0)
        case .headline: return (17, .semibold, 22, 0.0)
        case .body: return (17, .regular, 22, 0.0)
        case .subheadline: return (15, .regular, 20, -0.1)
        case .caption: return (13, .regular, 16, 0.0)
        case .footnote: return (12, .regular, 14, 0.0)
        }
    }

    public static func font(_ style: DSTextStyle, weight overrideWeight: UIFont.Weight? = nil) -> UIFont {
        let d = descriptor(for: style)
        let base = makeBaseFont(size: d.baseSize, weight: overrideWeight ?? d.weight)
        // Dynamic Type scaling
        let metrics = metrics(for: style)
        return metrics.scaledFont(for: base)
    }

    /// Paragraf stili + kerning (letter spacing) içeren NSAttributedString öznitelikleri.
    /// UILabel/UITextView gibi yerlerde kolay kullanım için.
    public static func attributes(_ style: DSTextStyle,
                                  weight: UIFont.Weight? = nil,
                                  textColor: UIColor? = nil,
                                  alignment: NSTextAlignment = .natural,
                                  lineBreak: NSLineBreakMode = .byTruncatingTail) -> [NSAttributedString.Key: Any] {
        let d = descriptor(for: style)
        let f = font(style, weight: weight)

        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = d.lineHeight
        paragraph.maximumLineHeight = d.lineHeight
        paragraph.alignment = alignment
        paragraph.lineBreakMode = lineBreak

        var attrs: [NSAttributedString.Key: Any] = [
            .font: f,
            .paragraphStyle: paragraph,
            .kern: d.letterSpacing
        ]
        if let c = textColor { attrs[.foregroundColor] = c }
        return attrs
    }

    // MARK: - Helpers

    /// Creates basic fonts from system or custom font family
    private static func makeBaseFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        // if custom font family uses
        if let customName = customFontName(for: weight),
           let custom = UIFont(name: customName, size: size) {
            return custom
        }
        // System font
        return .systemFont(ofSize: size, weight: weight)
    }

    private static func customFontName(for weight: UIFont.Weight) -> String? {
        // Medium/Bold için ayrı dosya adı verdiysen seç
        if weight >= .semibold, let bold = DSFontConfig.customFontNameBold { return bold }
        if weight == .medium, let medium = DSFontConfig.customFontNameMedium { return medium }
        return DSFontConfig.customFontNameRegular
    }

    /// Apple’ın textStyle kategorilerine eşleme (Dynamic Type için).
    private static func metrics(for style: DSTextStyle) -> UIFontMetrics {
        let textStyle: UIFont.TextStyle
        switch style {
        case .display: textStyle = .largeTitle
        case .title1: textStyle = .title1
        case .title2: textStyle = .title2
        case .headline: textStyle = .headline
        case .body: textStyle = .body
        case .subheadline: textStyle = .subheadline
        case .caption: textStyle = .caption1
        case .footnote: textStyle = .footnote
        }
        return UIFontMetrics(forTextStyle: textStyle)
    }
}
