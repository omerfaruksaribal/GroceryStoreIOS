import Foundation

struct ActivateAccountRequest: Codable {
    let email: String
    let activationCode: String
}

