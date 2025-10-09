import Foundation

enum RegisterViewState {
    case idle
    case submitting
    case success(email: String)
    case error(message: String)
}

final class RegisterVM {

    var username: String = ""
    var email: String = ""
    var password: String = ""

    var onStateChange: ((RegisterViewState) -> Void)?
    var onFieldErrors: (([String: String]) -> Void)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func submit() {
        if let error = validate(), !error.isEmpty {
            onFieldErrors?(error)
            onStateChange?(.error(message: "Please fix the highlighted fields."))
            return
        }

        onStateChange?(.submitting)

        let req = RegisterRequest(username: username, email: email, password: password)

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.authService.register(req)

                await MainActor.run {
                    if response.status == 200, let data = response.data {
                        self.onStateChange?(.success(email: data.email))
                    } else {
                        var fieldMap: [String: String] = [:]
                        response.errors?.forEach { error in
                            fieldMap[error.field] = error.errorMessage
                        }
                        if !fieldMap.isEmpty { self.onFieldErrors?(fieldMap) }

                        self.onStateChange?(.error(message: response.message))
                    }
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.error(message: "Something went wrong. Please try again later"))
                    print("LoginVM \(#line). Line Error: \(error.localizedDescription)")
                }
            }
        }
    }

    //  MARK: - Validator

    private func validate() -> [String: String]? {
        var errors: [String: String] = [:]

        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors["username"] = "Username is required"
        }

        if !isValidEmail(email) {
            errors["email"] = "Please enter a valid email address"
        }

        if password.count < 8 {
            errors["password"] = "Password must be at least 8 characters."
        }

        return errors
    }

    private func isValidEmail(_ string: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return string.range(of: pattern, options: .regularExpression) != nil
    }
}
