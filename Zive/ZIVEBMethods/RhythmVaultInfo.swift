
import Foundation
import Security

// MARK: - Key 定义
enum RhythmVaultSecureKey {
    case rhythmVaultDeviceId, rhythmVaultPassword

    var rhythmVaultKey: String {
        switch self {
        case .rhythmVaultDeviceId: return "rhythmVaultDeviceId3"
        case .rhythmVaultPassword: return "rhythmVaultPassword"
        }
    }
}

final class RhythmVaultBInfoStore {

    static let shared = RhythmVaultBInfoStore()
    private init() {}

    private func rhythmVaultSaveSecureValue(_ value: String, for key: RhythmVaultSecureKey) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        rhythmVaultDeleteSecureValue(key) // 先删除旧值

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rhythmVaultKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    private func rhythmVaultReadSecureValue(_ key: RhythmVaultSecureKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rhythmVaultKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        guard
            status == errSecSuccess,
            let resultData = data as? Data,
            let value = String(data: resultData, encoding: .utf8)
        else { return nil }
        return value
    }

    private func rhythmVaultDeleteSecureValue(_ key: RhythmVaultSecureKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rhythmVaultKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - 直接属性访问
    var rhythmVaultDeviceId: String {
        get { rhythmVaultReadSecureValue(.rhythmVaultDeviceId) ?? "" }
        set { rhythmVaultSaveSecureValue(newValue, for: .rhythmVaultDeviceId) }
    }

    var rhythmVaultPassword: String {
        get { rhythmVaultReadSecureValue(.rhythmVaultPassword) ?? "" }
        set { rhythmVaultSaveSecureValue(newValue, for: .rhythmVaultPassword) }
    }
}

// 卸载后不持久
enum RhythmVaultAppStorageKey {
  static let rhythmVaultIsB = "rhythmVaultIsB"
  static let rhythmVaultPushToken = "rhythmVaultPushToken"
  static let rhythmVaultH5Url = "rhythmVaultH5Url"
    static let rhythmVaultUserToken = "rhythmVaultUserToken"
}

final class RhythmVaultAppStorage {

  private static let rhythmVaultDefaults = UserDefaults.standard

  static var rhythmVaultIsB: Bool {
    get { rhythmVaultDefaults.bool(forKey: RhythmVaultAppStorageKey.rhythmVaultIsB) }
    set { rhythmVaultDefaults.set(newValue, forKey: RhythmVaultAppStorageKey.rhythmVaultIsB) }
  }
    
    static var rhythmVaultUserToken: String {
      get { rhythmVaultDefaults.string(forKey: RhythmVaultAppStorageKey.rhythmVaultUserToken) ?? ""}
      set { rhythmVaultDefaults.set(newValue, forKey: RhythmVaultAppStorageKey.rhythmVaultUserToken) }
    }

  static var rhythmVaultPushToken: String {
    get { rhythmVaultDefaults.string(forKey: RhythmVaultAppStorageKey.rhythmVaultPushToken) ?? "" }
    set { rhythmVaultDefaults.set(newValue, forKey: RhythmVaultAppStorageKey.rhythmVaultPushToken) }
  }

  static var rhythmVaultH5Url: String {
    get { rhythmVaultDefaults.string(forKey: RhythmVaultAppStorageKey.rhythmVaultH5Url) ?? "" }
    set { rhythmVaultDefaults.set(newValue, forKey: RhythmVaultAppStorageKey.rhythmVaultH5Url) }
  }
}

var rhythmVaultUsersOrderCode: String = ""
