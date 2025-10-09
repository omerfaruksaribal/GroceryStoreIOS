import UIKit

/// A text field with built-in states (normal/error/disabled),
/// caption label for helper or error text, and consistent paddings/borders.
public final class DSTextField: UIControl, UITextFieldDelegate {
    public enum State {
        case normal
        case error(message: String?)
        case disabled
    }

    public let textField = UITextField()
    public let captionLabel = UILabel()

    public var dsState: State = .normal { didSet { applyState() } } // <-- state didnt accepted so, renamed.

    public var contentInsets = UIEdgeInsets(top: DSSpacing.sm, left: DSSpacing.md, bottom: DSSpacing.sm, right: DSSpacing.md) {
        didSet { setNeedsLayout() }
    }

    public var onEditingChanged: ((String) -> Void)?
    public var onReturnTapped: (() -> Void)?

    //  MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    //  MARK: - Setup
    private func setup() {
        backgroundColor = DSColor.surfaceBase
        layer.cornerRadius = DSRadius.medium
        layer.borderWidth = 1
        layer.borderColor = DSColor.borderSoft.cgColor

        textField.delegate = self
        textField.font = DSFont.font(.body)
        textField.textColor = DSColor.textPrimary
        textField.tintColor = DSColor.primary
        textField.clearButtonMode = .whileEditing
        textField.adjustsFontForContentSizeCategory = true
        textField.textContentType = .oneTimeCode
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        captionLabel.font = DSFont.font(.caption)
        captionLabel.textColor = DSColor.textSecondary
        captionLabel.numberOfLines = 0

        addSubview(textField)
        addSubview(captionLabel)

        textField.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),

            captionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: DSSpacing.xs),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),
            captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        ])

        addTarget(self, action: #selector(textChanged), for: .editingChanged)
        applyState()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Keep border crisp on pixel boundaries
        layer.borderColor = currentBorderColor().cgColor
    }

    //  MARK: - State
    private func applyState() {
        switch dsState { // <--
        case .normal:
            isUserInteractionEnabled = true
            layer.borderColor = DSColor.borderSoft.cgColor
            captionLabel.textColor = DSColor.textSecondary
            captionLabel.text = nil
            backgroundColor = DSColor.surfaceBase

        case .error(let message):
            isUserInteractionEnabled = true
            layer.borderColor = DSColor.statusError.cgColor
            captionLabel.textColor = DSColor.statusError
            captionLabel.text = message
            backgroundColor = DSColor.surfaceBase

        case .disabled:
            isUserInteractionEnabled = false
            layer.backgroundColor = DSColor.borderSoft.cgColor
            captionLabel.textColor = DSColor.textDisabled
            backgroundColor = DSColor.disabledBackground
        }
    }

    private func currentBorderColor() -> UIColor {
        switch dsState { // <--
        case .error:
            return DSColor.statusError
        default:
            return DSColor.borderSoft
        }
    }

    //  MARK: - UITextFieldDelegate

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        onEditingChanged?(textField.text ?? "")
        sendActions(for: .editingChanged)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTapped?()
        return true
    }

    //  MARK: - API

    public var text: String? {
        get { textField.placeholder }
        set { textField.attributedPlaceholder = NSAttributedString(
            string: newValue ?? "",
            attributes: DSFont.attributes(.subheadline, textColor: DSColor.textSecondary)
        )}
    }

    @objc private func textChanged() {
        onEditingChanged?(textField.text ?? "")
    }


}
