import Foundation

struct ResetPasswordRequest: Codable {
    let email: String
    let resetPasswordCode: String
    let newPassword: String
}

