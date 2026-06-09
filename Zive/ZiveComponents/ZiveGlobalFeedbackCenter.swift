import SwiftUI
import Combine

enum ZiveToastStatus {
    case normal
    case error
    case success

    var iconName: String {
        switch self {
        case .normal:
            return "bell.fill"
        case .error:
            return "exclamationmark.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .normal:
            return ZiveStyle.ColorPalette.white
        case .error:
            return Color.red.opacity(0.95)
        case .success:
            return Color.green.opacity(0.95)
        }
    }
}

struct ZiveLoadingPayload {
    let text: String?
    let showsMask: Bool
}

struct ZiveToastPayload: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let status: ZiveToastStatus
}

final class ZiveGlobalFeedbackCenter: ObservableObject {
    static let shared = ZiveGlobalFeedbackCenter()

    @Published var ziveGlobalFeedbackLoading: ZiveLoadingPayload?
    @Published var ziveGlobalFeedbackToast: ZiveToastPayload?

    private var ziveGlobalFeedbackToastTask: Task<Void, Never>?

    func ziveGlobalFeedbackShowLoading(
        text: String? = nil,
        showsMask: Bool = true
    ) {
        ziveGlobalFeedbackLoading = ZiveLoadingPayload(
            text: text,
            showsMask: showsMask
        )
    }

    func ziveGlobalFeedbackHideLoading() {
        ziveGlobalFeedbackLoading = nil
    }

    func ziveGlobalFeedbackShowToast(
        text: String,
        status: ZiveToastStatus = .normal,
        duration: TimeInterval = 2
    ) {
        ziveGlobalFeedbackToastTask?.cancel()

        let ziveGlobalFeedbackPayload = ZiveToastPayload(
            text: text,
            status: status
        )
        ziveGlobalFeedbackToast = ziveGlobalFeedbackPayload

        ziveGlobalFeedbackToastTask = Task { [weak self] in
            let ziveGlobalFeedbackNanoseconds = UInt64(duration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ziveGlobalFeedbackNanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                if self?.ziveGlobalFeedbackToast?.id == ziveGlobalFeedbackPayload.id {
                    self?.ziveGlobalFeedbackToast = nil
                }
            }
        }
    }

    func ziveGlobalFeedbackDismissToast() {
        ziveGlobalFeedbackToastTask?.cancel()
        ziveGlobalFeedbackToast = nil
    }
}
