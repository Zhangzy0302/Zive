
import UIKit
import UserNotifications
import FBSDKCoreKit
import AdjustSdk

final class StepSyncAdjustManager: NSObject, AdjustDelegate {
    static let shared = StepSyncAdjustManager()

    private let stepSyncInstallToken = "meczga"
    private let stepSyncPurchaseToken = "3i7574"
    private let stepSyncAppToken = "t92ah3qdn5ds"
    private var stepSyncDidInitialize = false

    private override init() {}

    func stepSyncInitialize() {
        guard !stepSyncDidInitialize else {
            return
        }

        guard let stepSyncAdjustConfig = ADJConfig(
            appToken: stepSyncAppToken,
            environment: ADJEnvironmentProduction
        ) else {
            return
        }

        stepSyncAdjustConfig.logLevel = ADJLogLevel.verbose
        stepSyncAdjustConfig.enableSendingInBackground()
        stepSyncAdjustConfig.delegate = self

        Adjust.addGlobalCallbackParameter(
            RhythmVaultBInfoStore.shared.rhythmVaultDeviceId,
            forKey: "ta_distinct_id"
        )

        Adjust.attribution { [weak self] stepSyncAttribution in
            self?.adjustAttributionChanged(stepSyncAttribution)
        }

        Adjust.initSdk(stepSyncAdjustConfig)
        stepSyncDidInitialize = true
    }

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let stepSyncInstallEvent = ADJEvent(eventToken: stepSyncInstallToken)
        Adjust.trackEvent(stepSyncInstallEvent)
    }

    func stepSyncTrackPurchase(dollar: Double) {
        let stepSyncPurchaseEvent = ADJEvent(eventToken: stepSyncPurchaseToken)
        stepSyncPurchaseEvent?.setRevenue(dollar, currency: "USD")
        Adjust.trackEvent(stepSyncPurchaseEvent)
    }
}

class StepSyncAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        stepSyncRegisterPush(application)

        return true
    }

    private func stepSyncRegisterPush(_ application: UIApplication) {

        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let stepSyncPushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // 保存
        RhythmVaultAppStorage.rhythmVaultPushToken = stepSyncPushToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Push 注册失败:", error)
    }
}
