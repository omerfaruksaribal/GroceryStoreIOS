import Foundation

protocol AuthServiceProtocol {
    func register(_ request: RegisterRequest) async throws -> RegisterResponse

    func login(_ request: LoginRequest) async throws -> LoginResponse
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
}
