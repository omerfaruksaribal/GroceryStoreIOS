import Foundation
import Security

/// A secure, lightweight storage layer for access and refresh tokens.
/// It uses the iOS Keychain to persist tokens safely across app launches.
final class TokenStore {

    //  MARK: - Singleton
    static let shared = TokenStore()
    private init() {}

    // MARK: - Keys
    private let accessKey = "com.grocerystore.accessToken"
    private let refreshKey = "com.grocerystore.refreshToken"

    //  MARK: - public API

    /// Access token used for authorization headers.
    var accessToken: String? {
        get { read(for: accessKey) }
        set { write(value: newValue, for: accessKey) }
    }

    /// Refresh token used to renew the access token.
    var refreshToken: String? {
        get { read(for: refreshKey) }
        set { write(value: newValue, for: refreshKey) }
    }

    var isAuthenticated: Bool {
        return accessToken != nil
    }

    /// Clears both tokens from secure storage (logout).
    func clear() {
        delete(for: accessKey)
        delete(for: refreshKey)
    }

    //  MARK: - Keychain I/O Helpers


    private func read(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }

        return value
    }

    private func write(value: String?, for key: String) {
        // Delete existing record if any
        delete(for: key)

        guard let value = value, let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
