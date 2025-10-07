import Foundation

struct RegisterResponseData: Codable {
    let userId: String
    let email: String
    let message: String
}

typealias RegisterResponse = ApiResponse<RegisterResponseData>
