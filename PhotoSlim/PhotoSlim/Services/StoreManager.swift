import StoreKit
import Observation

@Observable
final class StoreManager: NSObject {
    var isPro: Bool = false
    var product: Product?
    var purchaseState: PurchaseState = .idle
    var dailyDeleteCount: Int = 0
    var lastResetDate: Date = Date()

    enum PurchaseState {
        case idle
        case loading
        case purchasing
        case purchased
        case failed(Error)
        case restored
    }

    static let proProductID = "com.zzoutuo.PhotoSlim.pro"
    static let freeDailyLimit = 5

    private var transactionListener: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?

    override init() {
        super.init()
        transactionListener = listenForTransactions()
        updateTask = Task { await loadProduct() }
    }

    deinit {
        transactionListener?.cancel()
        updateTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.proProductID])
            product = products.first
        } catch {
        }
    }

    func purchasePro() async {
        guard let product = product else { return }
        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPro = true
                purchaseState = .purchased
                await transaction.finish()
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
            purchaseState = .restored
        } catch {
            purchaseState = .failed(error)
        }
    }

    func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.proProductID {
                    isPro = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPro = false
    }

    func canDelete() -> Bool {
        if isPro { return true }
        resetDailyCountIfNeeded()
        return dailyDeleteCount < Self.freeDailyLimit
    }

    func recordDeletion(count: Int) {
        resetDailyCountIfNeeded()
        dailyDeleteCount += count
    }

    var remainingDeletesToday: Int {
        if isPro { return Int.max }
        resetDailyCountIfNeeded()
        return max(0, Self.freeDailyLimit - dailyDeleteCount)
    }

    private func resetDailyCountIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            dailyDeleteCount = 0
            lastResetDate = Date()
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    if transaction.productID == Self.proProductID {
                        await MainActor.run { self.isPro = true }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
