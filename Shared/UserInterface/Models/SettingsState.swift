//
//  SettingsState.swift
//  GitLab
//
//  Created by Stef Kors on 13/11/2024.
//


import SwiftUI
import StoreKit

enum AccountSlotStoreError: LocalizedError {
    case productUnavailable
    case purchasePending
    case purchaseCancelled
    case verificationFailed
    case unsupportedSlotCount

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "The next account slot product is not available right now."
        case .purchasePending:
            return "The purchase is pending approval."
        case .purchaseCancelled:
            return "The purchase was cancelled."
        case .verificationFailed:
            return "The App Store transaction could not be verified."
        case .unsupportedSlotCount:
            return "No more account slots are available for purchase."
        }
    }
}

enum AccountSlotPolicy {
    static let freeAccountLimit = 2
    static let maxSupportedAccounts = 10

    static let productIDsByTotalAccounts: [Int: String] = [
        3: "com.stefkors.gitlab.accountslot.3",
        4: "com.stefkors.gitlab.accountslot.4",
        5: "com.stefkors.gitlab.accountslot.5",
        6: "com.stefkors.gitlab.accountslot.6",
        7: "com.stefkors.gitlab.accountslot.7",
        8: "com.stefkors.gitlab.accountslot.8",
        9: "com.stefkors.gitlab.accountslot.9",
        10: "com.stefkors.gitlab.accountslot.10",
    ]

    static var allProductIDs: [String] {
        productIDsByTotalAccounts
            .sorted(by: { $0.key < $1.key })
            .map(\.value)
    }

    static func unlockedAccountCount(for productID: String) -> Int? {
        productIDsByTotalAccounts.first(where: { $0.value == productID })?.key
    }

    static func purchasedExtraSlots(for purchasedProductIDs: Set<String>) -> Int {
        let highestUnlockedCount = purchasedProductIDs.compactMap(unlockedAccountCount(for:)).max() ?? freeAccountLimit
        return max(0, highestUnlockedCount - freeAccountLimit)
    }

    static func maxAllowedAccounts(for purchasedProductIDs: Set<String>) -> Int {
        min(maxSupportedAccounts, freeAccountLimit + purchasedExtraSlots(for: purchasedProductIDs))
    }

    static func canAddAccount(currentCount: Int, purchasedProductIDs: Set<String>) -> Bool {
        currentCount < maxAllowedAccounts(for: purchasedProductIDs)
    }

    static func nextRequiredTotalAccountCount(for purchasedProductIDs: Set<String>) -> Int? {
        let nextCount = maxAllowedAccounts(for: purchasedProductIDs) + 1
        return nextCount <= maxSupportedAccounts ? nextCount : nil
    }

    static func nextRequiredProductID(for purchasedProductIDs: Set<String>) -> String? {
        guard let totalAccountCount = nextRequiredTotalAccountCount(for: purchasedProductIDs) else {
            return nil
        }

        return productIDsByTotalAccounts[totalAccountCount]
    }
}

struct AccountSlotProduct: Identifiable, Equatable {
    let totalAccountCount: Int
    let productID: String
    let displayName: String
    let description: String
    let displayPrice: String

    var id: String { productID }
}

struct AccountSlotEntitlementState: Equatable {
    var purchasedProductIDs: Set<String> = []

    var purchasedExtraSlots: Int {
        AccountSlotPolicy.purchasedExtraSlots(for: purchasedProductIDs)
    }

    var maxAllowedAccounts: Int {
        AccountSlotPolicy.maxAllowedAccounts(for: purchasedProductIDs)
    }

    var nextRequiredProductID: String? {
        AccountSlotPolicy.nextRequiredProductID(for: purchasedProductIDs)
    }
}

@MainActor
final class AccountSlotStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitlementState = AccountSlotEntitlementState()
    @Published private(set) var isLoadingProducts: Bool = false
    @Published private(set) var isRefreshingEntitlements: Bool = false

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = observeTransactionUpdates()
        Task {
            await refresh()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var purchasedExtraSlots: Int {
        entitlementState.purchasedExtraSlots
    }

    var maxAllowedAccounts: Int {
        entitlementState.maxAllowedAccounts
    }

    var nextRequiredProductID: String? {
        entitlementState.nextRequiredProductID
    }

    var nextProduct: Product? {
        guard let nextRequiredProductID else { return nil }
        return products.first(where: { $0.id == nextRequiredProductID })
    }

    var nextAccountSlotProduct: AccountSlotProduct? {
        guard let product = nextProduct,
              let totalAccountCount = AccountSlotPolicy.unlockedAccountCount(for: product.id) else {
            return nil
        }

        return AccountSlotProduct(
            totalAccountCount: totalAccountCount,
            productID: product.id,
            displayName: product.displayName,
            description: product.description,
            displayPrice: product.displayPrice
        )
    }

    func canAddAccount(currentCount: Int) -> Bool {
        AccountSlotPolicy.canAddAccount(currentCount: currentCount, purchasedProductIDs: entitlementState.purchasedProductIDs)
    }

    func refresh() async {
        async let productsTask: Void = loadProducts()
        async let entitlementsTask: Void = refreshEntitlements()
        _ = await (productsTask, entitlementsTask)
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let loadedProducts = try await Product.products(for: AccountSlotPolicy.allProductIDs)
            products = loadedProducts.sorted {
                let lhs = AccountSlotPolicy.unlockedAccountCount(for: $0.id) ?? 0
                let rhs = AccountSlotPolicy.unlockedAccountCount(for: $1.id) ?? 0
                return lhs < rhs
            }
        } catch {
            print("[StoreKit] Failed to load products: \(error.localizedDescription)")
        }
    }

    func refreshEntitlements() async {
        isRefreshingEntitlements = true
        defer { isRefreshingEntitlements = false }

        var purchasedProductIDs = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if AccountSlotPolicy.allProductIDs.contains(transaction.productID) {
                purchasedProductIDs.insert(transaction.productID)
            }
        }

        entitlementState = AccountSlotEntitlementState(purchasedProductIDs: purchasedProductIDs)
    }

    func purchaseNextSlot() async throws {
        if products.isEmpty {
            await loadProducts()
        }

        guard let product = nextProduct else {
            throw AccountSlotStoreError.productUnavailable
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            guard case .verified(let transaction) = verificationResult else {
                throw AccountSlotStoreError.verificationFailed
            }

            await transaction.finish()
            await refreshEntitlements()
        case .pending:
            throw AccountSlotStoreError.purchasePending
        case .userCancelled:
            throw AccountSlotStoreError.purchaseCancelled
        @unknown default:
            throw AccountSlotStoreError.verificationFailed
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refreshEntitlements()
            }
        }
    }

    static var preview: AccountSlotStore {
        let store = AccountSlotStore()
        store.entitlementState = AccountSlotEntitlementState(
            purchasedProductIDs: [
                "com.stefkors.gitlab.accountslot.3",
                "com.stefkors.gitlab.accountslot.4"
            ]
        )
        return store
    }
}

class SettingsState: ObservableObject {
    @AppStorage("Settings.showShareButton") var showShareButton: Bool = true

    @AppStorage("Settings.requestLanguage") var requestLanguage: RequestLanguageType = .auto
    var language: RequestLanguageType {
        .pullRequest
//        let context = ModelContext(.shared)
//        let accounts = (try? context.fetch(FetchDescriptor<Account>(sortBy: [.init(\.createdAt, order: .reverse)]))) ?? []
//        switch requestLanguage {
//        case .auto:
//            if let firstAccount = accounts.first {
//                switch firstAccount.provider {
//                case .GitHub:
//                    return .pullRequest
//                case .GitLab:
//                    return .mergeRequest
//                default:
//                    return .pullRequest
//                }
//            }
//            return .mergeRequest
//        default:
//            return requestLanguage
//        }
    }

    @Published private var isSettingActivationPolicy: Bool = false
    @AppStorage("Settings.activationPolicy") var activationPolicy: Bool = false {
        didSet {
#if os(macOS)
            let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy ? .regular : .accessory
            //            activationPolicy = newActivationPolicy

            print("newValue \(newActivationPolicy)")
            NSApplication.shared.setActivationPolicy(newActivationPolicy)
            /// After setting `.accessory` mode the app is deactivating itself, so we need to make it active again.
            if newActivationPolicy == .accessory {
                NSApp.activate()
            }
#endif
        }
    }
}
