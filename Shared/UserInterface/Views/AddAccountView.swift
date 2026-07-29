//
//  AddAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI
import SQLiteData

struct AddAccountView: View {
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]
    @EnvironmentObject private var accountSlotStore: AccountSlotStore
    @EnvironmentObject private var noticeState: NoticeState
    @State private var selectedView: GitProvider = .GitHub

    var body: some View {
        VStack {
            if accountSlotStore.canAddAccount(currentCount: accounts.count) {
                Picker(selection: $selectedView, content: {
                    Text("GitHub").tag(GitProvider.GitHub)
                    Text("GitLab").tag(GitProvider.GitLab)
                }, label: {
                    EmptyView()
                })
                .pickerStyle(.segmented)

                Form {
                    if selectedView == .GitHub {
                        GitHubAccountView()
                    } else {
                        GitLabAccountView()
                    }
                }
                .scrollDisabled(true)
                .formStyle(.grouped)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Form {
                    Section {
                        Text("You are using \(accounts.count) of \(accountSlotStore.maxAllowedAccounts) accounts.")

                        if let nextProduct = accountSlotStore.nextAccountSlotProduct {
                            Text("Buy one more permanent account slot for \(nextProduct.displayPrice) to unlock up to \(nextProduct.totalAccountCount) accounts.")
                                .foregroundStyle(.secondary)
#if os(macOS)
                            Button("Buy Next Account Slot") {
                                Task {
                                    await purchaseNextSlot()
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Restore Purchases") {
                                Task {
                                    await restorePurchases()
                                }
                            }
                            .buttonStyle(.bordered)
#else
                            Text("Extra account slots can be purchased on macOS and will unlock here automatically after restore.")
                                .foregroundStyle(.secondary)
#endif
                        } else if accountSlotStore.nextRequiredProductID != nil {
                            Text("Loading account slot purchase options...")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("You have reached the maximum supported account limit.")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Account Limit")
                    }
                }
                .formStyle(.grouped)
            }
        }
#if os(macOS)
        .scenePadding()
#else
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium])
#endif
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

#Preview("MacOS") {
    AddAccountView()
}

#Preview("iOS") {
    VStack {
        Spacer()
    }
    .sheet(isPresented: .constant(true), content: {
        AddAccountView()
    })
}
