import UIKit

final class ActivateAccountVC: UIViewController {

    //  MARK: - dependicies
    private let prefilledEmail: String?

    init(prefilledEmail: String? = nil) {
        self.prefilledEmail = prefilledEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //  MARK: - UI
    private let titleLabel: DSLabel = {
        let lbl = DSLabel(style: .title1, weight: .bold, textColor: DSColor.primary)
        lbl.text = "Activate Your Account"
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
        tf.textField.placeholder = "Enter your activation code"
        tf.dsState = .normal
        tf.textField.keyboardType = .numberPad
        return tf
    }()

    private let submitButton: DSButton = {
        let btn = DSButton(variant: .primary, size: .large)
        btn.setTitle("Activate Account", for: .normal)
        return btn
    }()

    private var loader: DSLoader?

    //  MARK: - VM
    private let viewModel = ActivateAccountVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColor.background

        layout()
        bindInputs()
        bindOutputs()

        if let email = prefilledEmail {
            emailField.text = email
            emailField.textField.isUserInteractionEnabled = false // Make read-only
            viewModel.email = email
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    //  MARK: - layout
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            emailField,
            codeField,
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

    //  MARK: - Bindings
    private func bindInputs() {
        emailField.onEditingChanged = { [weak self] text in
            guard let self else { return }
            self.viewModel.email = text
            if case .error = self.emailField.dsState {
                self.emailField.dsState = .normal
            }
        }

        codeField.onEditingChanged = { [weak self] code in
            guard let self else { return }
            self.viewModel.activationCode = code
            if case .error = self.codeField.dsState {
                self.codeField.dsState = .normal
            }
        }

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    private func bindOutputs() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                setLoading(false)
            case .submitting:
                setLoading(true)
            case .success:
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .success
                cfg.position = .bottom
                DSToastCenter.shared.show(text: "Account activated successfully!", in: self.view, config: cfg)

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

        viewModel.onFieldErrors = { [weak self] map in
            guard let self else { return }
            if let msg = map["email"] { self.emailField.dsState = .error(message: msg) }
            if let msg = map["activationCode"] { self.codeField.dsState = .error(message: msg) }
        }
    }

    //  MARK: - Actions
    @objc private func submitTapped() {
        view.endEditing(true)
        viewModel.submit()
    }

    //  MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.isLoading = loading

        if loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let loader = DSLoader(message: "Activating...")
                loader.show(in: self.view)
                self.loader = loader
            }
        } else {
            self.loader?.hide()
            self.loader = nil
        }
    }
}

