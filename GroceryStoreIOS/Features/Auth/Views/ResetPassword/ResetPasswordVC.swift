import UIKit

final class ResetPasswordVC: UIViewController {

    private let prefilledEmail: String?
    private let vm = ResetPasswordVM()
    private var loader: DSLoader?

    init(prefilledEmail: String? = nil) {
        self.prefilledEmail = prefilledEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel: DSLabel = {
        let lbl = DSLabel(style: .title1, weight: .bold, textColor: DSColor.primary)
        lbl.text = "Reset Your Password"
        return lbl
    }()
    private let emailField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "youremail@sample.com"
        tf.dsState = .normal
        return tf
    }()
    private let codeField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Reset Code"
        tf.dsState = .normal
        return tf
    }()
    private let newPasswordField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Enter Your New Password"
        tf.dsState = .normal
        tf.textField.isSecureTextEntry = true
        return tf
    }()
    private let submitButton: DSButton = {
        let btn = DSButton(variant: .primary, size: .large)
        btn.setTitle("Confirm reset", for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.background

        layout()
        bindInputs()
        bindOutputs()

        if let email = prefilledEmail {
            emailField.text = email
            emailField.textField.isUserInteractionEnabled = false
            vm.email = email
        }
    }

    private func layout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            emailField,
            codeField,
            newPasswordField,
            submitButton
        ])
        stack.axis = .vertical
        stack.spacing = DSSpacing.lg
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.lg),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.lg),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindInputs() {
        emailField.onEditingChanged = { [weak self] text in self?.vm.email = text }
        codeField.onEditingChanged = { [weak self] text in self?.vm.resetPasswordCode = text }
        newPasswordField.onEditingChanged = { [weak self] text in self?.vm.newPassword = text }

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    private func bindOutputs() {
        vm.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle: setLoading(false)
            case .submitting: setLoading(true)
            case .success:
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .success
                cfg.position = .bottom
                DSToastCenter.shared.show(text: "Password reset successfully!", in: self.view, config: cfg)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .error(let message):
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .error
                cfg.position = .top
                DSToastCenter.shared.show(text: message, in: self.view, config: cfg)
            }
        }
    }

    @objc private func submitTapped() {
        view.endEditing(true)
        vm.submit()
    }

    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.isLoading = loading

        if loading {
            let loader = DSLoader(message: "Loading...")
            loader.show(in: view)
            self.loader = loader
        } else {
            self.loader?.hide()
            self.loader = nil
        }
    }
}
