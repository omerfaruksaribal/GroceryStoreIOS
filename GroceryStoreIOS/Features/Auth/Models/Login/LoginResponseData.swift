import Foundation

struct LoginResponseData: Codable {
    let username: String
    let accessToken: String
    let refreshToken: String
}

typealias LoginResponse = ApiResponse<LoginResponseData>

