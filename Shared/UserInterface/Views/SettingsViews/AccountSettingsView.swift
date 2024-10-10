//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
// import UserNotifications
import SwiftData

struct AlertDetails: Identifiable {
    let name: String
    let id = UUID()
    let item: Account
}

 struct AccountSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query var accounts: [Account]
    @State private var showingAlert: Bool = false
    @State private var details: AlertDetails? = nil
    @State private var showCreateSheet: Bool = false
    let alertTitle: String = "Confirm deletion"
     var body: some View {
        Form {
            Section("GitLab Token") {
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
                                    Label("Delete", systemImage: "trash")
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                                .tint(.red)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                HStack {
                    Button("Add Account", action: { showCreateSheet.toggle() })
                        .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showCreateSheet, content: {
#if os(macOS)
                AddAccountView()
                    .interactiveDismissDisabled(false)
                    .presentationCompactAdaptation(.fullScreenCover)
#else
                NavigationView {
                    VStack {
                        Text("sdf")
                        // add sectioned view that goes step by step
                        // 1. server
                        // 2. key
                        // 3. verify
                        // 4. close

//                                            AddAccountView()
                    }
                    .border(Color.black)
                    .navigationBarBackButtonHidden(false)
                    .toolbar(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {

                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {

                            }
                        }
                    }
                }
//                    .interactiveDismissDisabled(false)
//                    .presentationCompactAdaptation(.sheet)
                    .presentationDetents([.medium])
#endif
                // .presentationContentInteraction(.resizes)
            })

            // Section("Notifications") {
            //     HStack {
            //         Text("Clear all Notifications")
            //         Spacer()
            //         Button("Clear", action: clearNotifications)
            //     }
            // }
        }
        .formStyle(.grouped)
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
                modelContext.delete(accounts[index])
            }
        }
    }

    private func deleteItem(_ item: Account) {
        withAnimation {
            modelContext.delete(item)
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

    // func clearNotifications() {
    //     let notifs = UNUserNotificationCenter.current()
    //     notifs.getDeliveredNotifications { delivereds in
    //         for delivered in delivereds {
    //             print("has delivered notif \(delivered.description)")
    //         }
    //     }
    // 
    //     notifs.getPendingNotificationRequests { pendings in
    //         for pending in pendings {
    //             print("has pending notif \(pending.description)")
    //         }
    //     }
    // 
    //     notifs.removeAllDeliveredNotifications()
    //     if #available(macOS 13.0, *) {
    //         notifs.setBadgeCount(0) { error in
    //             print("error? \(String(describing: error?.localizedDescription))")
    //         }
    //     } else {
    //         // Fallback on earlier versions
    //     }
    // }
}

#Preview {
    AccountSettingsView()
        .modelContainer(.shared)
}
