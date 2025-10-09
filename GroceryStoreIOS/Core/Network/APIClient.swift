import Foundation

final class APIClient {
    static let shared = APIClient()

    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()

    private init() {}

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
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, httpResponse) = try await session.data(for: request)

        guard let status = (httpResponse as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }

        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded
        } catch {
            throw NSError(domain: "APIClientDecode", code: status, userInfo: [
                NSLocalizedDescriptionKey: "Failed to decode response with status \(status). \(error)"
            ])
        }
    }
}
