import SwiftUI
import WebKit
import UIKit
import Combine
import ScreenShield

struct SedivaoBeiwWeb: View {
    let sedivaoBeiwWebUrlString: String
    @EnvironmentObject private var sedivaoBeiwWebNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var sedivaoBeiwWebIAPManager: CacoaPulseWalletIAPManager
    @EnvironmentObject private var sedivaoBeiwWebFeedbackCenter: ZiveGlobalFeedbackCenter
    @StateObject private var sedivaoBeiwWebBridge = SedivaoBeiwWebBridge()
    @State private var sedivaoBeiwWebIsLoading = true
    @State private var sedivaoBeiwWebLoadErrorText: String?
    @State private var sedivaoBeiwWebScreenCaptureObservation: NSKeyValueObservation?
    @State private var sedivaoBeiwWebIsScreenCaptured = false
    private var sedivaoBeiwWebIsBPackage: Bool {
        RhythmVaultAppStorage.rhythmVaultIsB
    }

    var body: some View {
        Group {
            if sedivaoBeiwWebIsBPackage {
                sedivaoBeiwWebContent
                    .protectScreenshot()
            } else {
                sedivaoBeiwWebContent
            }
        }
        .ignoresSafeArea()
        .onAppear {
            sedivaoBeiwWebStartScreenCaptureProtectionIfNeeded()
        }
        .onDisappear {
            sedivaoBeiwWebStopScreenCaptureProtection()
        }
    }

    private var sedivaoBeiwWebContent: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()
            
            if sedivaoBeiwWebIsBPackage && sedivaoBeiwWebIsLoading {
                GeometryReader { _ in
                    Image("ZIVEGuideBg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()
                }

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.02),
                        ZiveStyle.ColorPalette.background.opacity(0.35),
                        ZiveStyle.ColorPalette.background.opacity(0.82),
                        ZiveStyle.ColorPalette.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                if !sedivaoBeiwWebIsBPackage {
                    GrooveStreakTopNavigationBar(title: nil)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .padding(.top, 40)
                }

                if let sedivaoBeiwWebUrl = sedivaoBeiwWebResolvedUrl {
                    SedivaoBeiwWebContainer(
                        sedivaoBeiwWebUrl: sedivaoBeiwWebUrl,
                        sedivaoBeiwWebBridge: sedivaoBeiwWebBridge
                    ) {
                        sedivaoBeiwWebLoadErrorText = nil
                        sedivaoBeiwWebIsLoading = true
                    } sedivaoBeiwWebOnLoadingFinish: { sedivaoBeiwWebDuration in
                        sedivaoBeiwWebHandleLoadingFinish()
                        sedivaoBeiwWebRecordLoadingDuration(sedivaoBeiwWebDuration)
                    } sedivaoBeiwWebOnLoadingFailed: { sedivaoBeiwWebErrorText in
                        sedivaoBeiwWebIsLoading = false
                        sedivaoBeiwWebLoadErrorText = sedivaoBeiwWebErrorText
                    } sedivaoBeiwWebOnClose: {
                        RhythmVaultAppStorage.rhythmVaultUserToken = ""
                        sedivaoBeiwWebNavigator.weioZwivbePresentRoot(.eiwoqcZceioGuide)
                    } sedivaoBeiwWebOnRecharge: { sedivaoBeiwWebOrderCode, sedivaoBeiwWebBatchNo in
                        sedivaoBeiwWebHandleRecharge(
                            orderCode: sedivaoBeiwWebOrderCode,
                            batchNo: sedivaoBeiwWebBatchNo
                        )
                    } sedivaoBeiwWebOnOpenBrowser: { sedivaoBeiwWebUrlString in
                        sedivaoBeiwWebOpenExternalURL(sedivaoBeiwWebUrlString)
                    }
                    .background(Color.clear)
                    .ignoresSafeArea()
                    .opacity(sedivaoBeiwWebIsBPackage && sedivaoBeiwWebIsLoading ? 0 : 1)
                    
                } else {
                    sedivaoBeiwWebInvalidURLView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            if sedivaoBeiwWebIsLoading {
                sedivaoBeiwWebLoadingView
            }

            if let sedivaoBeiwWebLoadErrorText {
                sedivaoBeiwWebErrorView(sedivaoBeiwWebLoadErrorText)
            }

            if sedivaoBeiwWebIsBPackage && sedivaoBeiwWebIsScreenCaptured {
                sedivaoBeiwWebScreenCaptureBlockingView
            }
        }
        .ziveScreenBackground()
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }

    private var sedivaoBeiwWebResolvedUrl: URL? {
        if let sedivaoBeiwWebDirectUrl = URL(string: sedivaoBeiwWebUrlString),
           sedivaoBeiwWebDirectUrl.scheme != nil {
            return sedivaoBeiwWebDirectUrl
        }

        return URL(string: "https://\(sedivaoBeiwWebUrlString)")
    }

    private var sedivaoBeiwWebInvalidURLView: some View {
        VStack(spacing: 12) {
            Text("Invalid URL")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)

            Text(sedivaoBeiwWebUrlString)
                .font(ZiveStyle.FontBook.regular(14))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sedivaoBeiwWebScreenCaptureBlockingView: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(ZiveStyle.ColorPalette.white)

                Text("Screen recording not allowed")
                    .font(ZiveStyle.FontBook.boldItalic(18))
                    .foregroundStyle(ZiveStyle.ColorPalette.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
        .zIndex(300)
    }

    private var sedivaoBeiwWebLoadingView: some View {
        VStack(spacing: 28) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(ZiveStyle.ColorPalette.white)
                .scaleEffect(1.6)

            Text("Loading...")
                .font(ZiveStyle.FontBook.bold(16))
                .foregroundStyle(ZiveStyle.ColorPalette.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }

    private func sedivaoBeiwWebHandleLoadingFinish() {
        guard sedivaoBeiwWebIsBPackage else {
            sedivaoBeiwWebIsLoading = false
            return
        }

        Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            await MainActor.run {
                sedivaoBeiwWebIsLoading = false
            }
        }
    }

    private func sedivaoBeiwWebStartScreenCaptureProtectionIfNeeded() {
        guard sedivaoBeiwWebIsBPackage else {
            return
        }

        sedivaoBeiwWebIsScreenCaptured = UIScreen.main.isCaptured
        sedivaoBeiwWebScreenCaptureObservation = UIScreen.main.observe(
            \.isCaptured,
             options: [.new]
        ) { _, sedivaoBeiwWebChange in
            let sedivaoBeiwWebCaptured = sedivaoBeiwWebChange.newValue ?? false
            DispatchQueue.main.async {
                sedivaoBeiwWebIsScreenCaptured = sedivaoBeiwWebCaptured
            }
        }
    }

    private func sedivaoBeiwWebStopScreenCaptureProtection() {
        sedivaoBeiwWebScreenCaptureObservation?.invalidate()
        sedivaoBeiwWebScreenCaptureObservation = nil
        sedivaoBeiwWebIsScreenCaptured = false
    }

    private func sedivaoBeiwWebErrorView(_ sedivaoBeiwWebErrorText: String) -> some View {
        VStack(spacing: 12) {
            Text("Load failed")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)

            Text(sedivaoBeiwWebErrorText)
                .font(ZiveStyle.FontBook.regular(14))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.72))
                .multilineTextAlignment(.center)

            Button("Retry") {
                sedivaoBeiwWebLoadErrorText = nil
                sedivaoBeiwWebIsLoading = true
                sedivaoBeiwWebBridge.sedivaoBeiwWebReload()
            }
            .buttonStyle(.plain)
            .font(ZiveStyle.FontBook.boldItalic(17))
            .foregroundStyle(ZiveStyle.ColorPalette.textPink)
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZiveStyle.ColorPalette.background.opacity(0.86))
    }

    private func sedivaoBeiwWebRecordLoadingDuration(_ sedivaoBeiwWebDuration: Int) {
        guard RhythmVaultAppStorage.rhythmVaultIsB else {
            return
        }

        Task {
            try? await BeatBridgeApiCall().beatBridgeLoadingTimeRecord(sedivaoBeiwWebDuration)
        }
    }

    private func sedivaoBeiwWebHandleRecharge(orderCode: String, batchNo: String) {
        rhythmVaultUsersOrderCode = orderCode
        sedivaoBeiwWebFeedbackCenter.ziveGlobalFeedbackShowLoading(
            text: "Processing...",
            showsMask: true
        )
        sedivaoBeiwWebIAPManager.cacoaPulseWalletRecharge(productKeyId: batchNo) { sedivaoBeiwWebResult in
            sedivaoBeiwWebFeedbackCenter.ziveGlobalFeedbackHideLoading()
            switch sedivaoBeiwWebResult {
            case let .success(coins):
                sedivaoBeiwWebNotifyRechargeState(state: "success", coins: coins)
            case .cancelled:
                return
            case .pending:
                sedivaoBeiwWebNotifyRechargeState(state: "pending")
            case let .failed(message):
                sedivaoBeiwWebFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: message,
                    status: .error
                )
                sedivaoBeiwWebNotifyRechargeState(state: "failed")
            }
        }
    }

    private func sedivaoBeiwWebOpenExternalURL(_ sedivaoBeiwWebUrlString: String) {
        guard let sedivaoBeiwWebUrl = URL(string: sedivaoBeiwWebUrlString) else {
            sedivaoBeiwWebNotifyOpenState(state: "failed", urlString: sedivaoBeiwWebUrlString)
            return
        }

        UIApplication.shared.open(sedivaoBeiwWebUrl, options: [:]) { sedivaoBeiwWebSuccess in
            sedivaoBeiwWebNotifyOpenState(
                state: sedivaoBeiwWebSuccess ? "success" : "failed",
                urlString: sedivaoBeiwWebUrl.absoluteString
            )
        }
    }

    private func sedivaoBeiwWebNotifyOpenState(state: String, urlString: String) {
        let sedivaoBeiwWebJavaScript = """
        window.dispatchEvent(new CustomEvent('nativeOpenState', {
            detail: { state: '\(state)', url: '\(urlString)' }
        }));
        """
        sedivaoBeiwWebBridge.sedivaoBeiwWebEvaluateJavaScript(sedivaoBeiwWebJavaScript)
    }

    private func sedivaoBeiwWebNotifyRechargeState(state: String, coins: Int = 0) {
        let sedivaoBeiwWebJavaScript = """
        window.dispatchEvent(new CustomEvent('nativeRechargeState', {
            detail: { state: '\(state)', coins: \(coins) }
        }));
        """
        sedivaoBeiwWebBridge.sedivaoBeiwWebEvaluateJavaScript(sedivaoBeiwWebJavaScript)
    }
}

final class SedivaoBeiwWebBridge: ObservableObject {
    weak var sedivaoBeiwWebView: WKWebView?

    func sedivaoBeiwWebReload() {
        sedivaoBeiwWebView?.reload()
    }

    func sedivaoBeiwWebEvaluateJavaScript(_ sedivaoBeiwWebJavaScript: String) {
        DispatchQueue.main.async { [weak self] in
            self?.sedivaoBeiwWebView?.evaluateJavaScript(sedivaoBeiwWebJavaScript)
        }
    }
}

struct SedivaoBeiwWebContainer: UIViewRepresentable {
    let sedivaoBeiwWebUrl: URL
    let sedivaoBeiwWebBridge: SedivaoBeiwWebBridge
    var sedivaoBeiwWebOnLoadingStart: (() -> Void)?
    var sedivaoBeiwWebOnLoadingFinish: ((Int) -> Void)?
    var sedivaoBeiwWebOnLoadingFailed: ((String) -> Void)?
    var sedivaoBeiwWebOnClose: (() -> Void)?
    var sedivaoBeiwWebOnRecharge: ((String, String) -> Void)?
    var sedivaoBeiwWebOnOpenBrowser: ((String) -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let sedivaoBeiwWebConfiguration = WKWebViewConfiguration()
        let sedivaoBeiwWebContentController = WKUserContentController()
        sedivaoBeiwWebContentController.add(context.coordinator, name: "rechargePay")
        sedivaoBeiwWebContentController.add(context.coordinator, name: "Close")
        sedivaoBeiwWebContentController.add(context.coordinator, name: "openBrowser")
        sedivaoBeiwWebConfiguration.userContentController = sedivaoBeiwWebContentController
        sedivaoBeiwWebConfiguration.mediaTypesRequiringUserActionForPlayback = []
        sedivaoBeiwWebConfiguration.allowsInlineMediaPlayback = true

        let sedivaoBeiwWebView = WKWebView(frame: .zero, configuration: sedivaoBeiwWebConfiguration)
        sedivaoBeiwWebView.navigationDelegate = context.coordinator
        sedivaoBeiwWebView.uiDelegate = context.coordinator
        sedivaoBeiwWebView.backgroundColor = .clear
        sedivaoBeiwWebView.isOpaque = false
        sedivaoBeiwWebView.scrollView.backgroundColor = .clear
        sedivaoBeiwWebView.scrollView.contentInsetAdjustmentBehavior = .never
        sedivaoBeiwWebView.scrollView.contentInset = .zero
        sedivaoBeiwWebView.scrollView.scrollIndicatorInsets = .zero
        sedivaoBeiwWebView.allowsBackForwardNavigationGestures = true
        sedivaoBeiwWebBridge.sedivaoBeiwWebView = sedivaoBeiwWebView
        sedivaoBeiwWebView.load(URLRequest(url: sedivaoBeiwWebUrl))
        return sedivaoBeiwWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.sedivaoBeiwWebParent = self
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "rechargePay")
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "Close")
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "openBrowser")
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var sedivaoBeiwWebParent: SedivaoBeiwWebContainer
        var sedivaoBeiwWebStartTime: Date?

        init(_ sedivaoBeiwWebParent: SedivaoBeiwWebContainer) {
            self.sedivaoBeiwWebParent = sedivaoBeiwWebParent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            sedivaoBeiwWebStartTime = Date()
            sedivaoBeiwWebParent.sedivaoBeiwWebOnLoadingStart?()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let sedivaoBeiwWebDuration = sedivaoBeiwWebStartTime.map {
                Int(Date().timeIntervalSince($0) * 1000)
            } ?? 0
            sedivaoBeiwWebParent.sedivaoBeiwWebOnLoadingFinish?(sedivaoBeiwWebDuration)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            sedivaoBeiwWebParent.sedivaoBeiwWebOnLoadingFailed?(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            sedivaoBeiwWebParent.sedivaoBeiwWebOnLoadingFailed?(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let sedivaoBeiwWebUrl = navigationAction.request.url,
                  let sedivaoBeiwWebScheme = sedivaoBeiwWebUrl.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }

            if ["http", "https", "file", "about"].contains(sedivaoBeiwWebScheme) {
                decisionHandler(.allow)
                return
            }

            UIApplication.shared.open(sedivaoBeiwWebUrl, options: [:]) { [weak webView] sedivaoBeiwWebSuccess in
                let sedivaoBeiwWebState = sedivaoBeiwWebSuccess ? "success" : "failed"
                let sedivaoBeiwWebJavaScript = """
                window.dispatchEvent(new CustomEvent('nativeOpenState', {
                    detail: { state: '\(sedivaoBeiwWebState)', url: '\(sedivaoBeiwWebUrl.absoluteString)' }
                }));
                """
                DispatchQueue.main.async {
                    webView?.evaluateJavaScript(sedivaoBeiwWebJavaScript)
                }
            }
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let sedivaoBeiwWebUrl = navigationAction.request.url else {
                return nil
            }

            let sedivaoBeiwWebUrlString = sedivaoBeiwWebUrl.absoluteString.lowercased()
            if sedivaoBeiwWebUrl.scheme == "itms-apps"
                || sedivaoBeiwWebUrl.scheme == "itms-services"
                || sedivaoBeiwWebUrlString.contains("apps.apple.com") {
                UIApplication.shared.open(sedivaoBeiwWebUrl)
                return nil
            }

            webView.load(URLRequest(url: sedivaoBeiwWebUrl))
            return nil
        }

        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.grant)
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            switch message.name {
            case "rechargePay":
                guard let sedivaoBeiwWebDict = message.body as? [String: Any],
                      let sedivaoBeiwWebOrderCode = sedivaoBeiwWebDict["orderCode"] as? String,
                      let sedivaoBeiwWebBatchNo = sedivaoBeiwWebDict["batchNo"] as? String else {
                    return
                }
                sedivaoBeiwWebParent.sedivaoBeiwWebOnRecharge?(
                    sedivaoBeiwWebOrderCode,
                    sedivaoBeiwWebBatchNo
                )
            case "Close":
                sedivaoBeiwWebParent.sedivaoBeiwWebOnClose?()
            case "openBrowser":
                if let sedivaoBeiwWebDict = message.body as? [String: Any],
                   let sedivaoBeiwWebUrlString = sedivaoBeiwWebDict["url"] as? String {
                    sedivaoBeiwWebParent.sedivaoBeiwWebOnOpenBrowser?(sedivaoBeiwWebUrlString)
                } else if let sedivaoBeiwWebUrlString = message.body as? String {
                    sedivaoBeiwWebParent.sedivaoBeiwWebOnOpenBrowser?(sedivaoBeiwWebUrlString)
                }
            default:
                break
            }
        }
    }
}
