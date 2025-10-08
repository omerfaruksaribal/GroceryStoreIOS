import Foundation

enum LoginViewState {
    case idle
    case submitting
    case success(username: String)
    case error(message: String)
}

final class LoginVM {

    var username: String = ""
    var password: String = ""

    var onStateChange: ((LoginViewState) -> Void)?
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

        let req = LoginRequest(username: username, password: password)

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.authService.login(req)
                if response.status == 200, let data = response.data {
                    self.onStateChange?(.success(username: data.username))
                } else {
                    var fieldMap: [String: String] = [:]
                    response.errors?.forEach { error in
                        fieldMap[error.field] = error.errorMessage
                    }
                    if !fieldMap.isEmpty { self.onFieldErrors?(fieldMap) }

                    self.onStateChange?(.error(message: response.message))
                }
            } catch {
                self.onStateChange?(.error(message: "An unexpected error occurred."))
                print("LoginVM \(#line). Line Error: \(error.localizedDescription)")
            }
        }
    }

    //  MARK: - Validator

    private func validate() -> [String: String]? {
        return [:]
    }

    
}
