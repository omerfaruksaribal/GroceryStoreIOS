import Foundation

enum ForgotPasswordViewState {
    case idle
    case submitting
    case success
    case error(message: String)
}

final class ForgotPasswordVM {

    var email: String = ""

    // MARK: - Outputs
    var onStateChange: ((ForgotPasswordViewState) -> Void)?
    var onFieldErrors: (([String: String]) -> Void)?

    // MARK: - Dependencies
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

        let req = ForgotPasswordRequest(email: email)

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.authService.forgotPassword(req)
                await MainActor.run {
                    if response.status == 200 {
                        self.onStateChange?(.success)
                    } else {
                        self.onStateChange?(.error(message: response.message))
                    }
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.error(message: "Something went wrong. Please try again later."))
                    print("ForgotPasswordVM Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func validate() -> [String: String]? {
        var errors: [String: String] = [:]
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors["email"] = "Email is required."
        }
        return errors
    }
}
