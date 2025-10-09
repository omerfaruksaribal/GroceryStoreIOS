import UIKit

final class LoginVC: UIViewController {

    //  MARK: - UI

    private let titleLabel: DSLabel = {
        let lbl = DSLabel(style: .title1, weight: .bold, textColor: DSColor.primary)
        lbl.text = "Login to Your Account"
        return lbl
    }()

    private let usernameField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Username"
        tf.dsState = .normal
        return tf
    }()

    private let passwordField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Password"
        tf.dsState = .normal
        tf.textField.isSecureTextEntry = true
        return tf
    }()

    private let submitButton: DSButton = {
        let button = DSButton(variant: .primary, size: .large)
        button.setTitle("Login", for: .normal)
        return button
    }()

    private let navigateToRegisterButton: DSButton = {
        let button = DSButton(variant: .secondary, size: .medium)
        button.setTitle("Don't you have an account? Register", for: .normal)
        return button
    }()

    private var loader: DSLoader?

    //  MARK: - MVVM
    private let viewModel = LoginVM()

    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DSColor.background

        layout()
        bindInputs()
        bindOutputs()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    //  MARK: - Layout

    private func layout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            usernameField,
            passwordField,
            submitButton,
            navigateToRegisterButton
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

    //  MARK: - Bindings

    private func bindInputs() {
        usernameField.onEditingChanged = { [weak self] text in
            guard let self else { return }
            self.viewModel.username = text

            if case .error = self.usernameField.dsState {
                self.usernameField.dsState = .normal
            }
        }

        passwordField.onEditingChanged = { [weak self] text in
            guard let self else { return }
            self.viewModel.password = text
            
            if case .error = self.passwordField.dsState {
                self.passwordField.dsState = .normal
            }
        }

        passwordField.onReturnTapped = { [weak self] in
            self?.submitTapped()
        }

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        navigateToRegisterButton.addTarget(self, action: #selector(navigateToRegister), for: .touchUpInside)
    }

    private func bindOutputs() {
        // State Changes (loading / success / error)
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                self.setLoading(false)
            case .submitting:
                self.setLoading(true)
            case .success(let username):
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .success
                cfg.position = .bottom
                DSToastCenter.shared.show(text: "Welcome, \(username)!", in: self.view, config: cfg)
            case .error(let message):
                self.setLoading(false)
                var config = DSToast.Config()
                config.style = .error
                config.position = .top
                DSToastCenter.shared.show(text: message, in: self.view, config: config)
            }
        }

        viewModel.onFieldErrors = { [weak self] map in
            guard let self else { return }
            if let m = map["username"] {
                self.usernameField.dsState = .error(message: m)
            }
            if let m = map["password"] {
                self.passwordField.dsState = .error(message: m)
            }
        }
    }

    //  MARK: - Actions

    @objc private func submitTapped() {
        view.endEditing(true)
        viewModel.submit()
    }

    @objc private func navigateToRegister() {
        let vc = RegisterVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    //  MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.isLoading = loading

        if loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let loader = DSLoader(message: "Logging in...")
                loader.show(in: self.view)
                self.loader = loader
            }
        } else {
            self.loader?.hide()
            self.loader = nil
        }
    }

}
