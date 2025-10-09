import UIKit

final class RegisterVC: UIViewController {

    //  MARK: - UI

    private let titleLabel: DSLabel = {
        let lbl = DSLabel(style: .title1, weight: .bold, textColor: DSColor.primary)
        lbl.text = "Create Your Account"
        return lbl
    }()

    private let usernameField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Username"
        tf.dsState = .normal
        return tf
    }()

    private let emailField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "youremail@sample.com"
        tf.dsState = .normal
        return tf
    }()

    private let passwordField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "Password"
        tf.dsState = .normal
        tf.textField.isSecureTextEntry = true
        tf.textField.textContentType = .oneTimeCode
        return tf
    }()

    private let submitButton: DSButton = {
        let btn = DSButton(variant: .primary, size: .large)
        btn.setTitle("Create Account", for: .normal)
        return btn
    }()

    private let navigateToLoginButton: DSButton = {
        let btn = DSButton(variant: .secondary, size: .medium)
        btn.setTitle("Already have an account? Login", for: .normal)
        return btn
    }()

    private var loader: DSLoader?

    //  MARK: - MVVM
    private let viewModel = RegisterVM()

    //  MARK: - Lifecyle

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
        // Vertical stack to align controls
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            usernameField,
            emailField,
            passwordField,
            submitButton,
            navigateToLoginButton
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

        emailField.onEditingChanged = { [weak self] text in
            guard let self else { return }
            self.viewModel.email = text

            if case .error = self.emailField.dsState {
                self.emailField.dsState = .normal
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

        navigateToLoginButton.addTarget(self, action: #selector(navigateToLogin), for: .touchUpInside)
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
            case .success(let email):
                self.setLoading(false)
                self.showActivation(for: email)
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
            if let m = map["email"] {
                self.emailField.dsState = .error(message: m)
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

    @objc private func navigateToLogin() {
        let vc = LoginVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    //  MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.isLoading = loading

        if loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let loader = DSLoader(message: "Creating account...")
                loader.show(in: self.view)
                self.loader = loader
            }
        } else {
            self.loader?.hide()
            self.loader = nil
        }
    }

    private func showActivation(for email: String) {
        let vc = ActivateAccountVC(prefilledEmail: email)
        navigationController?.pushViewController(vc, animated: true)
    }
}
