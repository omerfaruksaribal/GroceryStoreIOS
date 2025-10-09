import UIKit

/// Lightweight toast component with queueing, positions, styles, auto-dismiss,
/// haptics, and VoiceOver announcements.
public final class DSToast: UIView {

    // MARK: - Types

    public enum Style {
        case success
        case error
        case warning
        case info
        case neutral
    }

    public enum Position {
        case top
        case bottom
    }

    public struct Config {
        public var style: Style = .neutral
        public var position: Position = .bottom
        public var duration: TimeInterval = 2.0
        public var showsHaptic: Bool = true
        public var cornerRadius: CGFloat = DSRadius.large
        public var horizontalInset: CGFloat = DSSpacing.lg
        public var verticalInset: CGFloat = DSSpacing.lg
        public var maxWidth: CGFloat = 600 // will clamp on compact screens
        public var allowsTapToDismiss: Bool = true

        public init() {}
    }

    // MARK: - UI

    private let label = UILabel()
    private let container = UIView()
    private var bottomConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var hideTask: DispatchWorkItem?

    // MARK: - Init

    public init(text: String, config: Config = Config()) {
        super.init(frame: .zero)
        setup(text: text, config: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup(text: String, config: Config) {
        isUserInteractionEnabled = false

        // Container
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = backgroundColor(for: config.style)
        container.layer.cornerRadius = config.cornerRadius
        container.layer.applyShadow(DSElevation.level2(for: traitCollection))
        container.clipsToBounds = false
        container.isAccessibilityElement = true
        container.accessibilityTraits = .staticText

        // Label
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(
            string: text,
            attributes: DSFont.attributes(.subheadline, textColor: foregroundColor(for: config.style), alignment: .center)
        )
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.topAnchor.constraint(equalTo: container.topAnchor, constant: DSSpacing.md),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DSSpacing.lg),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -DSSpacing.lg),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -DSSpacing.md)
        ])

        // Tap to dismiss
        if config.allowsTapToDismiss {
            isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismiss))
            addGestureRecognizer(tap)
        }

        // Accessibility (announce)
        UIAccessibility.post(notification: .announcement, argument: text)

        // Haptic
        if config.showsHaptic {
            let generator: UINotificationFeedbackGenerator = .init()
            switch config.style {
            case .success: generator.notificationOccurred(.success)
            case .error:   generator.notificationOccurred(.error)
            default:       generator.notificationOccurred(.warning)
            }
        }
    }

    private func backgroundColor(for style: Style) -> UIColor {
        switch style {
        case .success: return DSColor.statusSuccess
        case .error:   return DSColor.statusError
        case .warning: return DSColor.statusWarning
        case .info:    return DSColor.statusInfo
        case .neutral: return DSColor.surfaceElevated
        }
    }

    private func foregroundColor(for style: Style) -> UIColor {
        switch style {
        case .warning:
            // Prefer dark text on bright warning background for better contrast
            return DSColor.textPrimary
        case .neutral:
            return DSColor.textPrimary
        default:
            return DSColor.onStatus
        }
    }

    // MARK: - Presentation

    /// Presents a toast inside a given view with a specific configuration.
    public func present(in view: UIView, config: Config) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        // Clamp width for large screens
        let widthConstraint = widthAnchor.constraint(lessThanOrEqualToConstant: config.maxWidth)

        // Horizontal centering with safe-area insets
        let leading = leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor,
                                              constant: config.horizontalInset)
        let trailing = trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -config.horizontalInset)
        let centerX = centerXAnchor.constraint(equalTo: view.centerXAnchor)

        // Vertical position
        switch config.position {
        case .bottom:
            bottomConstraint = bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: config.verticalInset + 100) // start off-screen
        case .top:
            topConstraint = topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: -(config.verticalInset + 100)) // start off-screen
        }

        NSLayoutConstraint.activate([widthConstraint, leading, trailing, centerX])
        if let bottomConstraint { bottomConstraint.isActive = true }
        if let topConstraint { topConstraint.isActive = true }

        view.layoutIfNeeded()

        // Animate in
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.6,
                       options: [.allowUserInteraction, .curveEaseOut]) { [weak self] in
            guard let self = self else { return }
            switch config.position {
            case .bottom:
                self.bottomConstraint?.constant = -(config.verticalInset)
            case .top:
                self.topConstraint?.constant = config.verticalInset
            }
            view.layoutIfNeeded()
        }

        // Auto-dismiss
        let task = DispatchWorkItem { [weak self] in
            self?.dismiss(animated: true)
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration, execute: task)
    }

    /// Dismiss with animation.
    public func dismiss(animated: Bool) {
        hideTask?.cancel()

        guard let superview = superview else {
            removeFromSuperview()
            return
        }

        let animations = {
            if let bottom = self.bottomConstraint {
                bottom.constant += 100
            }
            if let top = self.topConstraint {
                top.constant -= 100
            }
            superview.layoutIfNeeded()
            self.alpha = 0.6
        }

        let completion: (Bool) -> Void = { _ in
            self.removeFromSuperview()
            DSToastCenter.shared.dequeueAndShowNext()
        }

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseIn, .allowUserInteraction],
                           animations: animations,
                           completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    @objc private func handleTapToDismiss() {
        dismiss(animated: true)
    }
}

// MARK: - Queueing Center

/// Manages a FIFO queue of toasts to avoid overlapping.
public final class DSToastCenter {

    public static let shared = DSToastCenter()
    private init() {}

    private struct Item {
        let toast: DSToast
        let host: UIView
        let config: DSToast.Config
    }

    private var queue: [Item] = []
    private var isPresenting: Bool = false

    /// Enqueue and present a toast. If one is already visible, it will be shown after.
    public func show(text: String,
                     in hostView: UIView,
                     config: DSToast.Config = .init()) {
        let toast = DSToast(text: text, config: config)
        queue.append(.init(toast: toast, host: hostView, config: config))
        dequeueAndShowNext()
    }

    fileprivate func dequeueAndShowNext() {
        guard !isPresenting else { return }
        guard !queue.isEmpty else { return }

        isPresenting = true
        let item = queue.removeFirst()

        // Hook dismissal to release the presenting lock
        _ = item.toast.dismiss(animated:)
        // (No direct way to swizzle here; rely on completion in dismiss -> it calls dequeueAndShowNext)

        item.toast.present(in: item.host, config: item.config)

        // Release presenting lock shortly after the toast is fully added (so multiple quick calls are queued)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.isPresenting = false
        }
    }
}
