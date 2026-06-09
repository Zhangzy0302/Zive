
import SwiftUI

@main
struct ZiveApp: App {
    @UIApplicationDelegateAdaptor(StepSyncAppDelegate.self)
    var appDelegate
    
    init() {
        if !QeixbgBriwyState.qeixbgBriwyDidSeedLocalData {
            ZiveLocalSeedFactory.ziveLocalSeedFactoryInitializeAllData()
            QeixbgBriwyState.qeixbgBriwyDidSeedLocalData = true
        }
        Task {
            await GrooveSignalPhoneInfo.shared.grooveSignalGetPhoneInfo()
            StepSyncAdjustManager.shared.stepSyncInitialize()
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack{
                WeioZwivbeRoute()
            }
            
        }
    }
}
