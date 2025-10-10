import Foundation

final class APIClient {
    static let shared = APIClient()

    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()

    private init() {}

    //  MARK: - Core Request

    /// Sends a JSON request and decodes a JSON response.
    /// - Parameters:
    ///   - path: Relative path from baseURL (e.g., "/auth/register")
    ///   - method: HTTP method
    ///   - body: Optional Encodable body to be JSON-encoded
    ///   - headers: Additional headers if any
    ///   - response: Decodable response type
    func send<Request: Codable, Response: Codable>(
        path: String,
        method: String = "GET",
        body: Request? = nil,
        headers: [String: String] = [:],
        response: Response.Type
    ) async throws -> Response {
        let url = NetworkConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach custom headers
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // Attach access token if avaliable
        if let token = TokenStore.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, httpResponse) = try await session.data(for: request)

        guard let status = (httpResponse as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }

        //  MARK: - Handle 401 (Unauthorized)
        if status == 401 {
            print("⚠️ Access token expired — attempting refresh...")

            let refreshed = try await refreshAccessToken()

            guard refreshed else {
                // Refresh Failed -> Clear tokens -> Throw Custom Error
                TokenStore.shared.clear()
                throw APIError.unauthorized
            }

            return try await retry(
                path: path,
                method: method,
                body: body,
                headers: headers,
                response: response
            )
        }

        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    //  MARK: - Retry Helper
    private func retry<Request: Codable, Response: Codable>(
        path: String,
        method: String,
        body: Request?,
        headers: [String: String],
        response: Response.Type
    ) async throws -> Response {
        var retryHeaders = headers

        if let newToken = TokenStore.shared.accessToken {
            retryHeaders["Authorization"] = "Bearer \(newToken)"
        }

        print("🔁 Retrying request with new token...")
        return try await send(
            path: path,
            method: method,
            body: body,
            headers: retryHeaders,
            response: response
        )
    }

    //  MARK: - Token Refresh
    /// Refreshes the access token using the refresh token stored in TokenStore.
    /// Returns true if successful, false otherwise.
    private func refreshAccessToken() async throws -> Bool {
        guard let refreshToken = TokenStore.shared.refreshToken else {
            print("No Refresh token available")
            return false
        }

        let requestBody = ["refreshToken": refreshToken]

        // Prepare refresh endpoint
        var request = URLRequest(url: NetworkConfig.baseURL.appendingPathComponent("auth/refresh-token"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }

            if http.statusCode == 200 {
                let decoded = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
                if let newAccess = decoded.data?.accessToken,
                   let newRefresh = decoded.data?.refreshToken {
                    TokenStore.shared.accessToken = newAccess
                    TokenStore.shared.refreshToken = refreshToken

                    print("Token refreshed successfully")
                    return true
                }
            } else {
                print("Refresh token request failed with status: \(http.statusCode)")
            }
        } catch {
            print("Token Refresh failed with error: \(error.localizedDescription)")
        }
        return false
    }
}

enum APIError: Error, LocalizedError {
    case unauthorized
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Session expired. Please log in again."
        case .decodingFailed(let reason):
            return "Failed to decode server response: \(reason)"
        }
    }
}
