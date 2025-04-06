import Foundation
import Security

class KeychainHelper {
    
    // Singleton instance
    static let shared = KeychainHelper()
    
    // Prevent instantiation from outside
    private init() {}
    
    // Function to save the token to Keychain
    func saveToken(token: String, forKey key: String) {
        // Convert the token to Data
        let tokenData = token.data(using: .utf8)!
        
        // Define the query for Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]
        
        // Try to add the token to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // If the item already exists, update it
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: tokenData
            ]
            SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        }
    }
    
    // Function to retrieve the token from Keychain
    func getToken(forKey key: String) -> String? {
        // Define the query for Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // If the token exists, return it
        if status == errSecSuccess {
            if let tokenData = item as? Data,
               let token = String(data: tokenData, encoding: .utf8) {
                return token
            }
        }
        
        // If the token doesn't exist, return nil
        return nil
    }
    
    // Function to delete the token from Keychain
    func deleteToken(forKey key: String) {
        // Define the query for Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Try to delete the token from Keychain
        SecItemDelete(query as CFDictionary)
    }
}

