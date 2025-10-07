import UIKit

/// Design System tipografisini kolay kullandıran UILabel.
/// Dynamic Type değişimlerine otomatik uyar.
public final class DSLabel: UILabel {

    private let style: DSTextStyle
    private let weight: UIFont.Weight?

    public init(style: DSTextStyle,
                weight: UIFont.Weight? = nil,
                textColor: UIColor? = nil,
                alignment: NSTextAlignment = .natural) {
        self.style = style
        self.weight = weight
        super.init(frame: .zero)

        adjustsFontForContentSizeCategory = true
        setStyle(style, weight: weight, color: textColor, alignment: alignment)

        // Dynamic Type güncellemelerini dinle
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeChanged),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    public func setStyle(_ style: DSTextStyle,
                         weight: UIFont.Weight? = nil,
                         color: UIColor? = nil,
                         alignment: NSTextAlignment = .natural) {
        let attrs = DSFont.attributes(style, weight: weight, textColor: color, alignment: alignment)
        let sampleText = self.text ?? ""
        attributedText = NSAttributedString(string: sampleText, attributes: attrs)
        numberOfLines = 0
    }

    public override var text: String? {
        didSet {
            // AttributedText'i, yeni metinle aynı stillerde yeniden kur
            let currentColor = (attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)
            let attrs = DSFont.attributes(style, weight: weight, textColor: currentColor)
            if let t = text { attributedText = NSAttributedString(string: t, attributes: attrs) }
        }
    }

    @objc private func contentSizeChanged() {
        // İçerik boyutu değiştiğinde fontu/metin özniteliklerini yeniden uygula
        let currentColor = (attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)
        let attrs = DSFont.attributes(style, weight: weight, textColor: currentColor)
        if let t = text { attributedText = NSAttributedString(string: t, attributes: attrs) }
    }
}
