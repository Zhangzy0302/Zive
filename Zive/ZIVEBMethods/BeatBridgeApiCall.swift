
import AdjustSdk
import Alamofire
import Foundation
import StoreKit

final class BeatBridgeApiCall {

  // MARK: - Base URL
  private let beatBridgeBaseURL = "https://opi.8acgspbj.link"

  // MARK: - Headers
  private var beatBridgeHeaders: HTTPHeaders {
    [
      "Content-Type": "application/json",
      "appVersion": GrooveSignalInformationCreate.grooveSignalAppVersion,
      "deviceNo": RhythmVaultBInfoStore.shared.rhythmVaultDeviceId,
      "pushToken": RhythmVaultAppStorage.rhythmVaultPushToken,
      "loginToken": RhythmVaultAppStorage.rhythmVaultUserToken,
      "appId": GrooveSignalInformationCreate.grooveSignalAppId,
    ]
  }

  // MARK: - Session
  private lazy var beatBridgeSession: Session = {
    let beatBridgeConfiguration = URLSessionConfiguration.default
    beatBridgeConfiguration.headers = .default
    return Session(configuration: beatBridgeConfiguration)
  }()
}

extension BeatBridgeApiCall {

  func beatBridgePayCall(
    purchaseID: String,
    serverVerificationData: String,
    orderCode: String
  ) async throws -> Bool {

    let body: [String: Any] = [
      "ngntwvbxAsct": purchaseID,
      "ndfscvAebfvp": serverVerificationData,
      "Nsecvhec": try beatBridgeJSONString(["orderCode": orderCode]),
    ]
    print("payload: \(body)")

    let data = try await beatBridgeRequest(
      path: "/opi/v1/mwsdvDShjbsp",
      body: body
    )
    print("pay code: \(data?["code"] ?? "null")")

    return data?["code"] as? String == "0000"
  }

  func beatBridgeGetDecision() async throws -> [String: Any]? {

    let beatBridgePhoneInfo = GrooveSignalPhoneInfo.shared

    let body: [String: Any] = [
      "mevbdSSVBTsvsd": 1,
      "mhrAWWVhgkbtn": beatBridgePhoneInfo.grooveSignalIsVpnActive,
      "coqkHUGiuhkwde": beatBridgePhoneInfo.grooveSignalLanguages,
      "nbwsthQIUUXbkas": beatBridgePhoneInfo.grooveSignalCoverAppList,
      "gbOhcbkavbsjt": beatBridgePhoneInfo.grooveSignalTimezone,
      "hnytkJgbywavbk": beatBridgePhoneInfo.grooveSignalKeyboards,
      "debug": 1,
    ]
      
    return try await beatBridgeRequest(
      path: "/opi/v1/dvqJHjxgfakfbo",
      body: body
    )
  }

  func beatBridgeQuickLogin() async throws -> [String: Any]? {

    let beatBridgePhoneInfo = GrooveSignalPhoneInfo.shared

    let beatBridgeAdjustID = await Adjust.adid()
    var body: [String: Any] = [
        "vkjlciLUHlaefa": beatBridgeAdjustID ?? "",  // adjust ID
        "hnejuKucuabbrd": RhythmVaultBInfoStore.shared.rhythmVaultPassword,  // password
        "bnKUHgqobhn": RhythmVaultBInfoStore.shared.rhythmVaultDeviceId,
        "jbkljhKjhehlkkv": [
        "countryCode": beatBridgePhoneInfo.grooveSignalCountryCode,
        "latitude": beatBridgePhoneInfo.grooveSignalLatitude,
        "longitude": beatBridgePhoneInfo.grooveSignalLongitude,
      ],
    ]

    if !RhythmVaultBInfoStore.shared.rhythmVaultPassword.isEmpty {
      body["ngMghkwkjgbed"] = RhythmVaultBInfoStore.shared.rhythmVaultPassword
    }

    return try await beatBridgeRequest(
      path: "/opi/v1/tdLKJHkjhajl",
      body: body
    )
  }

  func beatBridgeLoadingTimeRecord(_ loadingTime: Int) async throws -> [String: Any]? {

    let body: [String: Any] = [
      "jjLKJhoouoeho": "\(loadingTime)"
    ]

    return try await beatBridgeRequest(
      path: "/opi/v1/hfjkhsk/ejhkjt",
      body: body
    )
  }
}

extension BeatBridgeApiCall {

  fileprivate func beatBridgeRequest(
    path: String,
    body: [String: Any]
  ) async throws -> [String: Any]? {

    let beatBridgeJSONData = try JSONSerialization.data(withJSONObject: body)

    guard let beatBridgeJSONString = String(data: beatBridgeJSONData, encoding: .utf8) else {
      return nil
    }

    // 🔐 AES CBC 加密 → hex
    let beatBridgeEncryptedString = beatBridgeJSONString.grooveSignalBEncode()

    let beatBridgeResponse = try await beatBridgeSession.request(
      beatBridgeBaseURL + path,
      method: .post,
      parameters: nil,
      encoding: BeatBridgeRawStringEncoding(string: beatBridgeEncryptedString),
      headers: beatBridgeHeaders
    )
    .serializingData()
    .value

    return try beatBridgeParseResponse(beatBridgeResponse)
  }

  fileprivate func beatBridgeParseResponse(_ data: Data) throws -> [String: Any]? {
    let beatBridgeObject = try JSONSerialization.jsonObject(with: data)

    if let beatBridgeDict = beatBridgeObject as? [String: Any] {
      return beatBridgeDict
    }

    if let beatBridgeString = beatBridgeObject as? String,
      let beatBridgeData = beatBridgeString.data(using: .utf8)
    {
      return try JSONSerialization.jsonObject(with: beatBridgeData) as? [String: Any]
    }

    return nil
  }

  fileprivate func beatBridgeJSONString(_ dict: [String: Any]) throws -> String {
    let beatBridgeData = try JSONSerialization.data(withJSONObject: dict)
    return String(data: beatBridgeData, encoding: .utf8) ?? ""
  }
}

struct BeatBridgeRawStringEncoding: ParameterEncoding {

  let string: String

  func encode(
    _ urlRequest: URLRequestConvertible,
    with parameters: Parameters?
  ) throws -> URLRequest {

    var beatBridgeRequest = try urlRequest.asURLRequest()
    beatBridgeRequest.httpBody = string.data(using: .utf8)
    return beatBridgeRequest
  }
}
