import Foundation

enum ResetPasswordViewState {
    case idle
    case submitting
    case success
    case error(message: String)
}

final class ResetPasswordVM {

    var email: String = ""
    var resetPasswordCode: String = ""
    var newPassword: String = ""

    var onStateChange: ((ResetPasswordViewState) -> Void)?
    var onFieldErrors: (([String: String]) -> Void)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func submit() {
        if let errors = validate(), !errors.isEmpty {
            onFieldErrors?(errors)
            onStateChange?(.error(message: "Please fix the highlighted fields."))
            return
        }

        onStateChange?(.submitting)
        let req = ResetPasswordRequest(email: email, resetPasswordCode: resetPasswordCode, newPassword: newPassword)

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.authService.resetPassword(req)
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
                }
            }
        }
    }

    private func validate() -> [String: String]? {
        var errors: [String: String] = [:]
        if email.isEmpty { errors["email"] = "Email is required." }
        if resetPasswordCode.isEmpty { errors["resetPasswordCode"] = "Reset code is required." }
        if newPassword.count < 8 { errors["newPassword"] = "Password must be at least 8 characters." }
        return errors
    }
}
