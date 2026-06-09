
import CommonCrypto
import CoreLocation
import Foundation
import Network
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit
import Combine

// MARK: - AES + Hex

extension String {

  private static let grooveSignalAESKey = "66o3spbmw7t9q1p5"
  private static let grooveSignalAESIV = "6y0zfx2kaofz4orj"

  func grooveSignalBEncode() -> String {
    guard let grooveSignalData = self.data(using: .utf8),
      let grooveSignalEncrypted = grooveSignalAesCrypt(
        grooveSignalData: grooveSignalData,
        grooveSignalOperation: CCOperation(kCCEncrypt)
      )
    else {
      return ""
    }

    return grooveSignalEncrypted.map { String(format: "%02x", $0) }.joined()
  }

  func grooveSignalBDecrypt() -> String {
    guard let grooveSignalEncryptedData = Data(grooveSignalHexString: self),
      let grooveSignalDecrypted = grooveSignalAesCrypt(
        grooveSignalData: grooveSignalEncryptedData,
        grooveSignalOperation: CCOperation(kCCDecrypt)
      ),
      let grooveSignalResult = String(data: grooveSignalDecrypted, encoding: .utf8)
    else {
      return ""
    }

    return grooveSignalResult
  }

  private func grooveSignalAesCrypt(
    grooveSignalData: Data,
    grooveSignalOperation: CCOperation
  ) -> Data? {

    let grooveSignalKeyData = Self.grooveSignalAESKey.data(using: .utf8)!
    let grooveSignalIVData = Self.grooveSignalAESIV.data(using: .utf8)!

    let grooveSignalDataLength = grooveSignalData.count
    let grooveSignalOutLength = grooveSignalDataLength + kCCBlockSizeAES128

    var grooveSignalOutBytes = Data(count: grooveSignalOutLength)
    var grooveSignalFinalLength = 0

    let grooveSignalStatus = grooveSignalOutBytes.withUnsafeMutableBytes { grooveSignalOutBytesPtr -> CCCryptorStatus in

      guard let grooveSignalOutBase = grooveSignalOutBytesPtr.baseAddress else { return CCCryptorStatus(kCCMemoryFailure) }

      return grooveSignalData.withUnsafeBytes { grooveSignalDataPtr in
        grooveSignalKeyData.withUnsafeBytes { grooveSignalKeyPtr in
          grooveSignalIVData.withUnsafeBytes { grooveSignalIVPtr in

            CCCrypt(
              grooveSignalOperation,
              CCAlgorithm(kCCAlgorithmAES),
              CCOptions(kCCOptionPKCS7Padding),
              grooveSignalKeyPtr.baseAddress,
              kCCKeySizeAES128,
              grooveSignalIVPtr.baseAddress,
              grooveSignalDataPtr.baseAddress,
              grooveSignalDataLength,
              grooveSignalOutBase,
              grooveSignalOutLength,
              &grooveSignalFinalLength
            )
          }
        }
      }
    }

    guard grooveSignalStatus == kCCSuccess else { return nil }

    return grooveSignalOutBytes.prefix(grooveSignalFinalLength)
  }
}

extension Data {
  init?(grooveSignalHexString: String) {
    let grooveSignalHexLength = grooveSignalHexString.count / 2
    var grooveSignalData = Data(capacity: grooveSignalHexLength)

    var grooveSignalIndex = grooveSignalHexString.startIndex
    for _ in 0..<grooveSignalHexLength {
      let grooveSignalNextIndex = grooveSignalHexString.index(grooveSignalIndex, offsetBy: 2)
      guard grooveSignalNextIndex <= grooveSignalHexString.endIndex else { return nil }

      let grooveSignalBytes = grooveSignalHexString[grooveSignalIndex..<grooveSignalNextIndex]
      guard let grooveSignalNumber = UInt8(grooveSignalBytes, radix: 16) else { return nil }

      grooveSignalData.append(grooveSignalNumber)
      grooveSignalIndex = grooveSignalNextIndex
    }

    self = grooveSignalData
  }
}

class GrooveSignalInformationCreate {

  static let grooveSignalAppId: String = "22200102"
  static let grooveSignalAppVersion: String = "1.1.0"

  static let grooveSignalVerifyDate: DateComponents = DateComponents(
    year: 2026,
    month: 6,
    day: 11,
    hour: 12
  )

  static func grooveSignalBuildH5Url(grooveSignalBaseUrl: String, grooveSignalToken: String) -> String {
    let grooveSignalTimestamp = Int(Date().timeIntervalSince1970 * 1000)

    let grooveSignalOpenParams: [String: Any] = [
      "token": grooveSignalToken,
      "timestamp": grooveSignalTimestamp,
    ]
    guard let grooveSignalJsonData = try? JSONSerialization.data(withJSONObject: grooveSignalOpenParams),
      let grooveSignalJSONString = String(data: grooveSignalJsonData, encoding: .utf8)
    else {
      return ""
    }

    let grooveSignalEncodedParams = grooveSignalJSONString.grooveSignalBEncode()

    return "\(grooveSignalBaseUrl)?openParams=\(grooveSignalEncodedParams)&appId=\(grooveSignalAppId)"
  }
}

// MARK: - Location

class GrooveSignalLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

  static let shared = GrooveSignalLocationManager()
  @Published var grooveSignalShowLocationDialog: Bool = false
  private let grooveSignalManager = CLLocationManager()
  private var grooveSignalLocationContinuation: CheckedContinuation<CLLocation, Error>?

  override init() {
    super.init()
    grooveSignalManager.delegate = self
    grooveSignalManager.desiredAccuracy = kCLLocationAccuracyBest
  }
}

extension GrooveSignalLocationManager {

  func grooveSignalGetCurrentLocationAndAddress() async -> CLPlacemark? {

    let grooveSignalCanUseLocation = await grooveSignalCheckAndRequestLocation()
    if !grooveSignalCanUseLocation { return nil }

    do {
      let grooveSignalLocation = try await grooveSignalGetCurrentLocation()
      let grooveSignalPlacemark = try await grooveSignalReverseGeocode(grooveSignalLocation)
      return grooveSignalPlacemark
    } catch {
        await MainActor.run {
            ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
                text: "Positioning failed",
                status: .error
            )
        }
      return nil
    }
  }

  func grooveSignalCheckAndRequestLocation() async -> Bool {

    // 1️⃣ 检查系统定位开关
    guard CLLocationManager.locationServicesEnabled() else {
      await grooveSignalShowPermissionDialog()

      if !CLLocationManager.locationServicesEnabled() {
        grooveSignalShowLocationServiceDisabledToast()
        return false
      }
      return false
    }

    // 2️⃣ 检查权限
    let grooveSignalStatus = grooveSignalManager.authorizationStatus

    if grooveSignalStatus == .denied || grooveSignalStatus == .restricted {
      await grooveSignalShowPermissionDialog()

      let grooveSignalNewStatus = grooveSignalManager.authorizationStatus
      if grooveSignalNewStatus == .denied || grooveSignalNewStatus == .restricted {
        return false
      }
    }

    if grooveSignalStatus == .notDetermined {
      grooveSignalManager.requestWhenInUseAuthorization()
      return true
    }

    return true
  }

  private func grooveSignalGetCurrentLocation() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { grooveSignalContinuation in
      self.grooveSignalLocationContinuation = grooveSignalContinuation
      grooveSignalManager.requestLocation()
    }
  }
}

extension GrooveSignalLocationManager {

  func locationManager(
    _ grooveSignalManager: CLLocationManager,
    didUpdateLocations grooveSignalLocations: [CLLocation]
  ) {

    guard let grooveSignalLocation = grooveSignalLocations.first else {
      grooveSignalLocationContinuation?.resume(throwing: NSError())
      return
    }

    grooveSignalLocationContinuation?.resume(returning: grooveSignalLocation)
    grooveSignalLocationContinuation = nil
  }

  func locationManager(
    _ grooveSignalManager: CLLocationManager,
    didFailWithError grooveSignalError: Error
  ) {

    grooveSignalLocationContinuation?.resume(throwing: grooveSignalError)
    grooveSignalLocationContinuation = nil
  }
}

private extension GrooveSignalLocationManager {

  func grooveSignalReverseGeocode(_ grooveSignalLocation: CLLocation) async throws -> CLPlacemark? {

    try await withCheckedThrowingContinuation { grooveSignalContinuation in

      CLGeocoder().reverseGeocodeLocation(grooveSignalLocation) { grooveSignalPlacemarks, grooveSignalError in

        if let grooveSignalError {
          grooveSignalContinuation.resume(throwing: grooveSignalError)
          return
        }

        grooveSignalContinuation.resume(returning: grooveSignalPlacemarks?.first)
      }
    }
  }

  func grooveSignalShowLocationServiceDisabledToast() {
    DispatchQueue.main.async {
      ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
        text: "Please enable system location services.",
        status: .error
      )
    }
  }

  @MainActor
  func grooveSignalShowPermissionDialog() async {
    // 这里触发你的 SwiftUI 弹窗
    grooveSignalShowLocationDialog = true
  }
}

// MARK: - Phone Info

class GrooveSignalPhoneInfo {

  static let shared = GrooveSignalPhoneInfo()

  var grooveSignalLanguages: [String] = []
  var grooveSignalCountryCode: String = ""
  var grooveSignalLatitude: Double = 0
  var grooveSignalLongitude: Double = 0
  var grooveSignalCoverAppList: [String] = []
  var grooveSignalKeyboards: [String] = []
  var grooveSignalTimezone: String = ""
  var grooveSignalIsVpnActive: Int = 0
}

extension GrooveSignalPhoneInfo {

  func grooveSignalGetPhoneInfo() async {

    await withTaskGroup(of: Void.self) { grooveSignalGroup in

      grooveSignalGroup.addTask { await self.grooveSignalGetLanguages() }
      grooveSignalGroup.addTask { await self.grooveSignalGetTimezone() }
      grooveSignalGroup.addTask { await self.grooveSignalGetInstalledApps() }
      grooveSignalGroup.addTask { await self.grooveSignalCheckVPN() }
      grooveSignalGroup.addTask {
        await self.grooveSignalGetSystemKeyboards()
      }

      if RhythmVaultBInfoStore.shared.rhythmVaultDeviceId.isEmpty {
        print("RhythmVaultBInfoStore.getDevid: \(RhythmVaultBInfoStore.shared.rhythmVaultDeviceId)")
        grooveSignalGroup.addTask {
          RhythmVaultBInfoStore.shared.rhythmVaultDeviceId = await self.grooveSignalGetDeviceId(grooveSignalAppId: GrooveSignalInformationCreate.grooveSignalAppId)
        }
      }
    }
  }
}

extension GrooveSignalPhoneInfo {

  func grooveSignalGetLanguages() async {
    self.grooveSignalLanguages = Locale.preferredLanguages
  }

  func grooveSignalGetTimezone() async {
    self.grooveSignalTimezone = TimeZone.current.identifier
  }

  func grooveSignalCheckVPN() async {

    var grooveSignalIsVPN = false

    if let grooveSignalSettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
      let grooveSignalScopes = grooveSignalSettings["__SCOPED__"] as? [String: Any]
    {

      for grooveSignalKey in grooveSignalScopes.keys {
        if grooveSignalKey.contains("tap") || grooveSignalKey.contains("tun") || grooveSignalKey.contains("ppp")
          || grooveSignalKey.contains("ipsec")
        {
          grooveSignalIsVPN = true
          break
        }
      }
    }

    self.grooveSignalIsVpnActive = grooveSignalIsVPN ? 1 : 0
  }

  func grooveSignalGetInstalledApps() async {

    var grooveSignalInstalledApps: [String] = []

    for grooveSignalApp in grooveSignalKnownApps {
      if let grooveSignalUrl = URL(string: "\(grooveSignalApp.grooveSignalScheme)://"),
        await UIApplication.shared.canOpenURL(grooveSignalUrl)
      {
        grooveSignalInstalledApps.append(grooveSignalApp.grooveSignalName)
      }
    }

    self.grooveSignalCoverAppList = grooveSignalInstalledApps
  }

  func grooveSignalGetSystemKeyboards() async {
    await MainActor.run {
      let grooveSignalLanguages = UITextInputMode.activeInputModes.compactMap {
        $0.primaryLanguage
      }
      self.grooveSignalKeyboards = grooveSignalLanguages
    }
  }

  func grooveSignalGetDeviceId(grooveSignalAppId: String) async -> String {

    let grooveSignalIdentifier = await UIDevice.current.identifierForVendor?.uuidString ?? ""
    return grooveSignalIdentifier + grooveSignalAppId
  }
}

// MARK: - Known Apps

struct GrooveSignalApp {
  let grooveSignalName: String
  let grooveSignalScheme: String
}

let grooveSignalKnownApps = [
  GrooveSignalApp(grooveSignalName: "WhatsApp", grooveSignalScheme: "whatsapp"),
  GrooveSignalApp(grooveSignalName: "Instagram", grooveSignalScheme: "instagram"),
  GrooveSignalApp(grooveSignalName: "Facebook", grooveSignalScheme: "fb"),
  GrooveSignalApp(grooveSignalName: "TikTok", grooveSignalScheme: "tiktok"),
  GrooveSignalApp(grooveSignalName: "GoogleMaps", grooveSignalScheme: "comgooglemaps"),
  GrooveSignalApp(grooveSignalName: "twitter", grooveSignalScheme: "tweetie"),
  GrooveSignalApp(grooveSignalName: "qq", grooveSignalScheme: "mqq"),
  GrooveSignalApp(grooveSignalName: "weiChat", grooveSignalScheme: "wechat"),
  GrooveSignalApp(grooveSignalName: "Aliapp", grooveSignalScheme: "alipay"),
]
