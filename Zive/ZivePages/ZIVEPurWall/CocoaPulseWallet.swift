import SwiftUI
import StoreKit
import Combine

struct CacoaPulseWalletItem: Identifiable {
    let cacoaPulseWalletProductKeyId: String
    let cacoaPulseWalletCoinCount: Int
    let cacoaPulseWalletPrice: Double

    var id: String {
        cacoaPulseWalletProductKeyId
    }

    var cacoaPulseWalletPriceText: String {
        String(format: "$%.2f", cacoaPulseWalletPrice)
    }
}

let cacoaPulseWalletProducts: [CacoaPulseWalletItem] = [
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "bymivmaulvjtjxic",
        cacoaPulseWalletCoinCount: 400,
        cacoaPulseWalletPrice: 0.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "xszzshoetckmmlna",
        cacoaPulseWalletCoinCount: 800,
        cacoaPulseWalletPrice: 1.99
    ),
    
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "ulfogvnnsvxusprs",
        cacoaPulseWalletCoinCount: 2450,
        cacoaPulseWalletPrice: 4.99
    ),
    
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "yxbscetvxjnzundj",
        cacoaPulseWalletCoinCount: 5150,
        cacoaPulseWalletPrice: 9.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "ibcsaqkbztemplcz",
        cacoaPulseWalletCoinCount: 10800,
        cacoaPulseWalletPrice: 19.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "qvmdkztnxjafwpec",
        cacoaPulseWalletCoinCount: 14900,
        cacoaPulseWalletPrice: 29.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "lryhsoibucgntkvm",
        cacoaPulseWalletCoinCount: 19800,
        cacoaPulseWalletPrice: 39.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "qwslbkwufrxmicyu",
        cacoaPulseWalletCoinCount: 29400,
        cacoaPulseWalletPrice: 49.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "wpejzqcnlrafhtsx",
        cacoaPulseWalletCoinCount: 34500,
        cacoaPulseWalletPrice: 69.99
    ),
    CacoaPulseWalletItem(
        cacoaPulseWalletProductKeyId: "pjtcatxtvgfaqqmb",
        cacoaPulseWalletCoinCount: 63700,
        cacoaPulseWalletPrice: 99.99
    )
]

enum CacoaPulseWalletPurchaseResult {
    case success(coins: Int)
    case cancelled
    case pending
    case failed(message: String)
}

final class CacoaPulseWalletIAPManager: NSObject, ObservableObject {
    @Published var cacoaPulseWalletStoreProducts: [SKProduct] = []
    @Published var cacoaPulseWalletIsPurchasing = false

    private var cacoaPulseWalletRequest: SKProductsRequest?
    private var cacoaPulseWalletPurchaseCompletion: ((CacoaPulseWalletPurchaseResult) -> Void)?
    private var cacoaPulseWalletRetryCount = 0
    private var cacoaPulseWalletTotalRequestCount = 0
    private let cacoaPulseWalletMaxTotalRequestCount = 10
    private let cacoaPulseWalletMaxRetryCount = 10
    private var cacoaPulseWalletIsRequesting = false

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        cacoaPulseWalletRequest?.cancel()
        SKPaymentQueue.default().remove(self)
    }

    func cacoaPulseWalletFetchProducts() {
        guard cacoaPulseWalletTotalRequestCount < cacoaPulseWalletMaxTotalRequestCount else {
            return
        }

        guard !cacoaPulseWalletIsRequesting else {
            return
        }

        guard cacoaPulseWalletStoreProducts.isEmpty else {
            return
        }

        cacoaPulseWalletIsRequesting = true
        cacoaPulseWalletTotalRequestCount += 1

        let cacoaPulseWalletProductIds = Set(
            cacoaPulseWalletProducts.map { $0.cacoaPulseWalletProductKeyId }
        )

        cacoaPulseWalletRequest?.cancel()
        cacoaPulseWalletRequest = SKProductsRequest(productIdentifiers: cacoaPulseWalletProductIds)
        cacoaPulseWalletRequest?.delegate = self
        cacoaPulseWalletRequest?.start()
    }

    func cacoaPulseWalletRecharge(
        productKeyId: String,
        completion: @escaping (CacoaPulseWalletPurchaseResult) -> Void
    ) {
        guard !cacoaPulseWalletIsPurchasing else {
            completion(.pending)
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            completion(.failed(message: "Payments not allowed"))
            return
        }

        guard let cacoaPulseWalletProduct = cacoaPulseWalletStoreProducts.first(where: {
            $0.productIdentifier == productKeyId
        }) else {
            completion(.failed(message: "Product not found"))
            return
        }

        cacoaPulseWalletIsPurchasing = true
        cacoaPulseWalletPurchaseCompletion = completion

        let cacoaPulseWalletPayment = SKPayment(product: cacoaPulseWalletProduct)
        SKPaymentQueue.default().add(cacoaPulseWalletPayment)
    }

    private func cacoaPulseWalletProductConfig(productId: String) -> CacoaPulseWalletItem? {
        cacoaPulseWalletProducts.first {
            $0.cacoaPulseWalletProductKeyId == productId
        }
    }

    private func cacoaPulseWalletFinishPurchase(_ cacoaPulseWalletResult: CacoaPulseWalletPurchaseResult) {
        DispatchQueue.main.async {
            self.cacoaPulseWalletIsPurchasing = false
            self.cacoaPulseWalletPurchaseCompletion?(cacoaPulseWalletResult)
            self.cacoaPulseWalletPurchaseCompletion = nil
        }
    }

    private func cacoaPulseWalletReceiptDataString() -> String {
        guard let cacoaPulseWalletReceiptURL = Bundle.main.appStoreReceiptURL,
              let cacoaPulseWalletReceiptData = try? Data(contentsOf: cacoaPulseWalletReceiptURL) else {
            return ""
        }

        return cacoaPulseWalletReceiptData.base64EncodedString()
    }

    private func cacoaPulseWalletHandlePurchasedTransaction(
        _ cacoaPulseWalletTransaction: SKPaymentTransaction
    ) {
        guard let cacoaPulseWalletProduct = cacoaPulseWalletProductConfig(
            productId: cacoaPulseWalletTransaction.payment.productIdentifier
        ) else {
            SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)
            cacoaPulseWalletFinishPurchase(.failed(message: "Product not found"))
            return
        }

        guard RhythmVaultAppStorage.rhythmVaultIsB else {
            SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)
            StepSyncAdjustManager.shared.stepSyncTrackPurchase(
                dollar: cacoaPulseWalletProduct.cacoaPulseWalletPrice
            )
            cacoaPulseWalletFinishPurchase(
                .success(coins: cacoaPulseWalletProduct.cacoaPulseWalletCoinCount)
            )
            return
        }

        let cacoaPulseWalletPurchaseID = cacoaPulseWalletTransaction.transactionIdentifier ?? ""
        let cacoaPulseWalletVerificationData = cacoaPulseWalletReceiptDataString()
        let cacoaPulseWalletOrderCode = rhythmVaultUsersOrderCode

        Task {
            do {
                let cacoaPulseWalletDidVerify = try await BeatBridgeApiCall().beatBridgePayCall(
                    purchaseID: cacoaPulseWalletPurchaseID,
                    serverVerificationData: cacoaPulseWalletVerificationData,
                    orderCode: cacoaPulseWalletOrderCode
                )

                await MainActor.run {
                    SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)

                    if cacoaPulseWalletDidVerify {
                        StepSyncAdjustManager.shared.stepSyncTrackPurchase(
                            dollar: cacoaPulseWalletProduct.cacoaPulseWalletPrice
                        )
                        cacoaPulseWalletFinishPurchase(
                            .success(coins: cacoaPulseWalletProduct.cacoaPulseWalletCoinCount)
                        )
                    } else {
                        cacoaPulseWalletFinishPurchase(.failed(message: "Purchase unverified"))
                    }
                }
            } catch {
                await MainActor.run {
                    SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)
                    cacoaPulseWalletFinishPurchase(
                        .failed(message: error.localizedDescription)
                    )
                }
            }
        }
    }
}

extension CacoaPulseWalletIAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.cacoaPulseWalletIsRequesting = false
            self.cacoaPulseWalletRetryCount = 0
            self.cacoaPulseWalletStoreProducts = response.products

            if response.products.isEmpty {
                self.cacoaPulseWalletRetryFetch()
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.cacoaPulseWalletIsRequesting = false
            self.cacoaPulseWalletRetryFetch()
        }
    }

    private func cacoaPulseWalletRetryFetch() {
        cacoaPulseWalletRetryCount += 1

        guard cacoaPulseWalletRetryCount < cacoaPulseWalletMaxRetryCount,
              cacoaPulseWalletTotalRequestCount < cacoaPulseWalletMaxTotalRequestCount else {
            return
        }

        let cacoaPulseWalletDelay = pow(2.0, Double(cacoaPulseWalletRetryCount))
        DispatchQueue.main.asyncAfter(deadline: .now() + cacoaPulseWalletDelay) {
            self.cacoaPulseWalletFetchProducts()
        }
    }
}

extension CacoaPulseWalletIAPManager: SKPaymentTransactionObserver {
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for cacoaPulseWalletTransaction in transactions {
            switch cacoaPulseWalletTransaction.transactionState {
            case .purchased:
                cacoaPulseWalletHandlePurchasedTransaction(cacoaPulseWalletTransaction)

            case .failed:
                SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)

                if let cacoaPulseWalletError = cacoaPulseWalletTransaction.error as? SKError,
                   cacoaPulseWalletError.code == .paymentCancelled {
                    cacoaPulseWalletFinishPurchase(.cancelled)
                } else {
                    cacoaPulseWalletFinishPurchase(
                        .failed(
                            message: cacoaPulseWalletTransaction.error?.localizedDescription ?? "Unknown error"
                        )
                    )
                }

            case .restored:
                SKPaymentQueue.default().finishTransaction(cacoaPulseWalletTransaction)
                DispatchQueue.main.async {
                    self.cacoaPulseWalletIsPurchasing = false
                }

            case .purchasing:
                break

            case .deferred:
                cacoaPulseWalletPurchaseCompletion?(.pending)
                DispatchQueue.main.async {
                    self.cacoaPulseWalletIsPurchasing = false
                }

            @unknown default:
                break
            }
        }
    }
}

struct CocoaPulseWallet: View {
    @EnvironmentObject private var cacoaPulseWalletIAPManager: CacoaPulseWalletIAPManager
    @EnvironmentObject private var cacoaPulseWalletUserStore: OrbitUserStore
    @EnvironmentObject private var cacoaPulseWalletFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var cacoaPulseWalletGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack(alignment: .top) {
            Image("ZIVEWalPgBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 256)
                .frame(maxWidth: .infinity)
                .padding(.top, 31)
            VStack(spacing: 0) {
                cacoaPulseWalletTopBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        Image("ZIVEGoldCoin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 143, height: 143)
                            .padding(.top, 12)

                        ForEach(cacoaPulseWalletProducts) { cacoaPulseWalletItem in
                            cacoaPulseWalletRechargeRow(item: cacoaPulseWalletItem)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .ziveScreenBackground()
        .navigationBarHidden(true)
        .onAppear {
            cacoaPulseWalletIAPManager.cacoaPulseWalletFetchProducts()
        }
        .onChange(of: cacoaPulseWalletIAPManager.cacoaPulseWalletIsPurchasing) { cacoaPulseWalletIsPurchasing in
            if cacoaPulseWalletIsPurchasing {
                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowLoading(text: "Processing...")
            } else {
                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackHideLoading()
            }
        }
    }

    private var cacoaPulseWalletTopBar: some View {
        HStack {
            GrooveStreakTopNavigationBar(title: "Wallet")

            ZStack {
                

                HStack(spacing: 6) {
                    Image("ZIVEGoldCoin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)

                    Text("\(cacoaPulseWalletCurrentUser?.orbitUserCoinCount ?? 0)")
                        .font(ZiveStyle.FontBook.boldItalic(16))
                        .foregroundStyle(ZiveStyle.ColorPalette.white)
                }.padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
            }
        }
    }

    private func cacoaPulseWalletRechargeRow(item: CacoaPulseWalletItem) -> some View {
        Button {
            cacoaPulseWalletGuestGate.CBnxweZGoLogRequireLogin {
                cacoaPulseWalletRecharge(item)
            }
        } label: {
            HStack {
                Text("\(item.cacoaPulseWalletCoinCount)")
                    .font(ZiveStyle.FontBook.boldItalic(20))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPink)

                Spacer()

                Text(item.cacoaPulseWalletPriceText)
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPink)
            }
            .padding(.horizontal, 24)
            .frame(height: 56)
            .background(Color.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var cacoaPulseWalletCurrentUser: OrbitUserModel? {
        let cacoaPulseWalletCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cacoaPulseWalletUserStore.orbitUserFetch(by: cacoaPulseWalletCurrentUserId)
    }

    private func cacoaPulseWalletRecharge(_ item: CacoaPulseWalletItem) {
        guard let cacoaPulseWalletCurrentUser else {
            cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        guard !cacoaPulseWalletIAPManager.cacoaPulseWalletStoreProducts.isEmpty else {
            cacoaPulseWalletIAPManager.cacoaPulseWalletFetchProducts()
            cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Products are loading",
                status: .normal
            )
            return
        }

        cacoaPulseWalletIAPManager.cacoaPulseWalletRecharge(
            productKeyId: item.cacoaPulseWalletProductKeyId
        ) { cacoaPulseWalletResult in
            switch cacoaPulseWalletResult {
            case let .success(coins):
                let cacoaPulseWalletDidRecharge = cacoaPulseWalletUserStore.orbitUserAdjustCoinCount(
                    userId: cacoaPulseWalletCurrentUser.id,
                    delta: coins
                )

                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: cacoaPulseWalletDidRecharge ? "Recharge successful" : "Recharge failed",
                    status: cacoaPulseWalletDidRecharge ? .success : .error
                )

            case .cancelled:
                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Purchase cancelled",
                    status: .normal
                )

            case .pending:
                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Purchase pending",
                    status: .normal
                )

            case let .failed(message):
                cacoaPulseWalletFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: message,
                    status: .error
                )
                cacoaPulseWalletIAPManager.cacoaPulseWalletFetchProducts()
            }
        }
    }
}
