import UIKit

final class ForgotPasswordVC: UIViewController {

    private let titleLabel: DSLabel = {
        let lbl = DSLabel(style: .title1, weight: .bold, textColor: DSColor.primary)
        lbl.text = "Forgot Password"
        return lbl
    }()
    private let emailField: DSTextField = {
        let tf = DSTextField()
        tf.textField.placeholder = "youremail@sample.com"
        tf.dsState = .normal
        return tf
    }()
    private let submitButton: DSButton = {
        let btn = DSButton(variant: .primary, size: .large)
        btn.setTitle("Send Reset Code", for: .normal)
        return btn
    }()

    private var loader: DSLoader?

    private let vm = ForgotPasswordVM()

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

    private func layout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, emailField, submitButton])
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
        emailField.onEditingChanged = { [weak self] text in
            guard let self else { return }
            self.vm.email = text
            if case .error = self.emailField.dsState { self.emailField.dsState = .normal }
        }

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    private func bindOutputs() {
        vm.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                self.setLoading(false)
            case .submitting:
                self.setLoading(true)
            case .success:
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .success
                cfg.position = .bottom
                DSToastCenter.shared.show(text: "Reset code sent successfully!", in: self.view, config: cfg)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    let resetVC = ResetPasswordVC(prefilledEmail: self.vm.email)
                    self.navigationController?.pushViewController(resetVC, animated: true)
                }

            case .error(let message):
                self.setLoading(false)
                var cfg = DSToast.Config()
                cfg.style = .error
                cfg.position = .top
                DSToastCenter.shared.show(text: message, in: self.view, config: cfg)
            }
        }

        vm.onFieldErrors = { [weak self] map in
            guard let self else { return }
            if let msg = map["email"] {
                self.emailField.dsState = .error(message: msg)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let loader = DSLoader(message: "Sending...")
                loader.show(in: self.view)
                self.loader = loader
            }
        } else {
            self.loader?.hide()
            self.loader = nil
        }
    }
}
