import Foundation

struct ForgotPasswordResponseData: Codable {
    let message: String
}

typealias ForgotPasswordResponse = ApiResponse<ForgotPasswordResponseData>

