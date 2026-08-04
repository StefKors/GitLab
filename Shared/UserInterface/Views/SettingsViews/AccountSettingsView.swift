//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import UserNotifications
import SQLiteData

struct AlertDetails: Identifiable {
    let name: String
    let id = UUID()
    let item: Account
}

// createing a new token via a link
// https://github.com/settings/tokens/new?description=Graphite+(Created+on+Jun%206,%2012:14%20PM)&scopes=repo,read:org,read:user,user:email

struct AccountSettingsView: View {
    @Dependency(\.defaultDatabase) private var database
    @FetchAll private var accounts: [Account]
    @EnvironmentObject private var accountSlotStore: AccountSlotStore
    @EnvironmentObject private var noticeState: NoticeState
    @State private var showingAlert: Bool = false
    @State private var details: AlertDetails?
    @State private var showCreateSheet: Bool = false
    private let alertTitle: String = "Confirm deletion"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsTitleView(label: "Account", systemImage: "person.2.fill", fill: .blue.darker(by: 15))
                .padding()
                .padding(.leading, 4)

            Divider()

            Form {
                Section {
                    HStack {
                        Text("Current usage")
                        Spacer()
                        Text("\(accounts.count) of \(accountSlotStore.maxAllowedAccounts)")
                            .foregroundStyle(.secondary)
                    }

                    if accounts.isEmpty {
                        AccountListEmptyView()
                    } else {
                        List {
                            ForEach(accounts) { account in
                                HStack {
                                    GitProviderView(provider: account.provider)
                                        .frame(width: 25, height: 25, alignment: .center)
                                    AccountRow(account: account)
                                    Spacer()

                                    Button(role: .destructive) {
                                        showAlert(for: account)
                                    } label: {
                                        SwiftUI.Label("Delete", systemImage: "trash")
                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.borderless)
                                    .tint(.red)
                                    .padding(.trailing, 4)
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .padding(.vertical, 4)
                    }
                    if accounts.count < accountSlotStore.maxAllowedAccounts {
                        HStack {
                            Button("Add Account", action: { showCreateSheet.toggle() })
                                .buttonStyle(.borderedProminent)
                        }
                    } else if let nextProduct = accountSlotStore.nextAccountSlotProduct {
                        Button {
#if os(macOS)
                            Task {
                                await purchaseNextSlot()
                            }
#else
                            showCreateSheet.toggle()
#endif
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .center) {
                                    Image(systemName: "sparkles.rectangle.stack.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.95))
                                    Spacer()
                                    Text(nextProduct.displayPrice)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text("Purchase account slot")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text("Unlock account \(nextProduct.totalAccountCount) and keep adding more GitHub or GitLab accounts.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.88))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.blue.darker(by: 10),
                                        Color.cyan.darker(by: 20)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    } else if accountSlotStore.nextRequiredProductID != nil {
                        HStack {
                            ProgressView()
                            Text("Loading account slot purchase options...")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Maximum supported account limit unlocked.")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Tokens")
                        .foregroundStyle(.secondary)
                }
                .sheet(isPresented: $showCreateSheet, content: {
#if os(macOS)
                    AddAccountView()
                        .interactiveDismissDisabled(false)
                        .presentationCompactAdaptation(.fullScreenCover)
#else
                    AddAccountView()
                        .interactiveDismissDisabled(false)
                        .presentationCompactAdaptation(.sheet)
#endif
                    // .presentationContentInteraction(.resizes)
                })

                Section("Notifications") {
                    HStack {
                        Text("Clear all notifications")
                        Spacer()
                        Button("Clear", action: clearNotifications)
                    }
                }

                Section("Account Slots") {
                    HStack {
                        Text("Current usage")
                        Spacer()
                        Text("\(accounts.count) of \(accountSlotStore.maxAllowedAccounts)")
                            .foregroundStyle(.secondary)
                    }

                    if let nextProduct = accountSlotStore.nextAccountSlotProduct {
                        HStack {
                            Text("Next slot price")
                            Spacer()
                            Text(nextProduct.displayPrice)
                                .foregroundStyle(.secondary)
                        }

#if os(macOS)
                        Button("Buy account slot \(nextProduct.totalAccountCount)") {
                            Task {
                                await purchaseNextSlot()
                            }
                        }
                        .disabled(accountSlotStore.isLoadingProducts || accountSlotStore.isRefreshingEntitlements)
#endif
                    } else if accountSlotStore.nextRequiredProductID != nil {
                        Text("Loading account slot purchase options...")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Maximum supported account limit unlocked.")
                            .foregroundStyle(.secondary)
                    }

#if os(macOS)
                    Button("Restore Purchases") {
                        Task {
                            await restorePurchases()
                        }
                    }
                    .disabled(accountSlotStore.isRefreshingEntitlements)
#endif
                }
            }
        }
        .formStyle(.grouped)
        .groupBoxStyle(PlainGroupBoxStyle())
        .alert(
            alertTitle,
            isPresented: $showingAlert,
            presenting: details
        ) { details in
            Button(role: .destructive) {
                deleteItem(details.item)
            } label: {
                Text("Remove \(details.name)")
            }
        } message: { details in
            Text("This \(details.name) account will be removed immediatly. You can't undo this action.")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                deleteItem(accounts[index])
            }
        }
    }

    private func deleteItem(_ item: Account) {
        Task {
            do {
                try await database.write { db in
                    try Account.delete(item).execute(db)
                }
            } catch {
                print("[Delete Account] Failed to delete account: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(for account: Account) {
        if let url = URL(string: account.instance), let host = url.host() {
            details = AlertDetails(name: host, item: account)
        } else {
            details = AlertDetails(name: account.instance, item: account)
        }
        showingAlert.toggle()
    }

    private func clearNotifications() {
        let notifications = UNUserNotificationCenter.current()
        notifications.removeAllDeliveredNotifications()
        notifications.removeAllPendingNotificationRequests()
        if #available(macOS 13.0, iOS 16.0, *) {
            notifications.setBadgeCount(0) { error in
                if let error {
                    print("[Notifications] Failed to reset badge count: \(error.localizedDescription)")
                }
            }
        }
    }

    @MainActor
    private func purchaseNextSlot() async {
        do {
            try await accountSlotStore.purchaseNextSlot()
            noticeState.addNotice(
                notice: NoticeMessage(
                    label: "Account slot purchased successfully.",
                    type: .information
                )
            )
        } catch AccountSlotStoreError.purchaseCancelled {
            return
        } catch {
            noticeState.addNotice(
                notice: NoticeMessage(
                    label: error.localizedDescription,
                    type: .error
                )
            )
        }
    }

    @MainActor
    private func restorePurchases() async {
        do {
            try await accountSlotStore.restorePurchases()
            noticeState.addNotice(
                notice: NoticeMessage(
                    label: "Purchases restored.",
                    type: .information
                )
            )
        } catch {
            noticeState.addNotice(
                notice: NoticeMessage(
                    label: error.localizedDescription,
                    type: .error
                )
            )
        }
    }
}

//#Preview {
//    AccountSettingsView()
//        .modelContainer(.shared)
//}
