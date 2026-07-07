import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.recoverylog.pro.monthly"

    @Published var isPro: Bool = false
    @Published var product: Product?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
        Task { await load() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func load() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            product = nil
        }
        await refreshEntitlements()
    }

    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            default:
                break
            }
        } catch {
            // purchase failed or was cancelled
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var proActive = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                proActive = true
            }
        }
        isPro = proActive
    }
}
