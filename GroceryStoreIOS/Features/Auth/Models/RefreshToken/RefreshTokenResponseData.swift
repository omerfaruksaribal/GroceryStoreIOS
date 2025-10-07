import Foundation

struct RefreshTokenResponseData: Codable {
    let accessToken: String
    let refreshToken: String
}

typealias RefreshTokenResponse = ApiResponse<RefreshTokenResponseData>

