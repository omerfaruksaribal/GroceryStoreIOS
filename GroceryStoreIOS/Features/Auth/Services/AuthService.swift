import Foundation


protocol AuthServiceProtocol {
    func register(_ request: RegisterRequest) async throws -> RegisterResponse

    func login(_ request: LoginRequest) async throws -> LoginResponse

    func activateAccount(_ request: ActivateAccountRequest) async throws -> ApiResponse<EmptyResponse>

    func refreshToken(_ request: RefreshTokenRequest) async throws -> RefreshTokenResponse

    func forgotPassword(_ request: ForgotPasswordRequest) async throws -> ForgotPasswordResponse

    func resetPassword(_ request: ResetPasswordRequest) async throws -> ApiResponse<EmptyResponse>
}

final class AuthService: AuthServiceProtocol {

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    /// POST /auth/register
    func register(_ request: RegisterRequest) async throws -> RegisterResponse {
        let response: RegisterResponse = try await client.send(
            path: "/auth/register",
            method: "POST",
            body: request,
            headers: [:],
            response: RegisterResponse.self
        )
        return response
    }

    /// POST /auth/login
    func login(_ request: LoginRequest) async throws -> LoginResponse {
        let response: LoginResponse = try await client.send(
            path: "/auth/login",
            method: "POST",
            body: request,
            headers: [:],
            response: LoginResponse.self
        )
        return response
    }

    /// PATCH /auth/activate
    func activateAccount(_ request: ActivateAccountRequest) async throws -> ApiResponse<EmptyResponse> {
        let response: ApiResponse<EmptyResponse> = try await client.send(
            path: "/auth/activate",
            method: "PATCH",
            body: request,
            headers: [:],
            response: ApiResponse<EmptyResponse>.self
        )
        return response
    }

    /// POST /auth/refresh-token
    func refreshToken(_ request: RefreshTokenRequest) async throws -> RefreshTokenResponse {
        let response: RefreshTokenResponse = try await client.send(
            path: "/auth/refresh-token",
            method: "POST",
            body: request,
            headers: [:],
            response: RefreshTokenResponse.self
        )
        return response
    }

    /// POST /auth/forgot-password
    func forgotPassword(_ request: ForgotPasswordRequest) async throws -> ForgotPasswordResponse {
        let response: ForgotPasswordResponse = try await client.send(
            path: "/auth/forgot-password",
            method: "POST",
            body: request,
            headers: [:],
            response: ForgotPasswordResponse.self
        )
        return response
    }

    /// PATCH /auth/reset-password
    func resetPassword(_ request: ResetPasswordRequest) async throws -> ApiResponse<EmptyResponse> {
        let response: ApiResponse<EmptyResponse> = try await client.send(
            path: "/auth/reset-password",
            method: "PATCH",
            body: request,
            headers: [:],
            response: ApiResponse<EmptyResponse>.self
        )
        return response
    }
}
