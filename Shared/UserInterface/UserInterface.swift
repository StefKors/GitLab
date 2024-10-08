//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

struct NetworkEvent: Identifiable {
    let status: Int
    let label: String
    let timestamp: Date = .now
    let id: UUID = UUID()
}

class NetworkState: ObservableObject {
    @Published var events: [NetworkEvent] = []

    func success(label: String) {
        let event = NetworkEvent(status: 200, label: label)
        events.append(event)
    }

    func fail(label: String) {
        let event = NetworkEvent(status: 404, label: label)
        events.append(event)
    }
}

/// TODO: Show different accounts
/// TODO: Show different git providers (GL / GH)
/// TODO: Filter by type
/// TODO: show assigned issues
/// TODO: widget?
/// TODO: timeline view updates
/// TODO: Reinstate clear notifications setting
/// TODO: Split networking
struct UserInterface: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var mergeRequests: [MergeRequest]
    @Query private var accounts: [Account]
    @Query private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests

    @State private var timelineDate: Date = .now

    @StateObject private var networkState: NetworkState = .init()

    var filteredMergeRequests: [MergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    var body: some View {
        HStack(alignment: .top) {
            TimelineView(.periodic(from: timelineDate, by: 12)) { context in
                VStack(alignment: .center, spacing: 10) {
                    Picker(selection: $selectedView, content: {
                        Text("Your Merge Requests").tag(QueryType.authoredMergeRequests)
                        Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
                    }, label: {
                        EmptyView()
                    })
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 0)

                    LaunchpadView(repos: repos)

                    // Disabled in favor for real notifications?
                    NoticeListView()
                        .padding(.horizontal)

                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            MergeRequestList(
                                mergeRequests: filteredMergeRequests,
                                accounts: accounts,
                                selectedView: selectedView
                            )
                            Spacer()
                        }
                        .padding(.horizontal)
                        .scrollBounceBehavior(.basedOnSize)
                    }

                    if accounts.isEmpty {
                        BaseTextView(message: "Setup your accounts in the settings")
                    } else if filteredMergeRequests.isEmpty {
                        BaseTextView(message: "All done 🥳")
                            .foregroundStyle(.secondary)
                    }

                    LastUpdateMessageView(lastUpdate: context.date)
                }
                .task(id: context.date) {
                    await fetchReviewRequestedMRs()
                    await fetchAuthoredMRs()
                    await fetchRepos()
                }
//                .frame(idealWidth: 500, maxWidth: 500)
            }
        }
    }

    /// TODO: Cleanup and move both into the same function
    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            do {
                let results = try await NetworkManager.shared.fetchReviewRequestedMergeRequests(with: account)?.map { mr in
                    mr.account = account
                    mr.type = .reviewRequestedMergeRequests
                    return mr
                }
                if let results {
                    results.map { mr in
                        mr.reference
                    }
                    // TODO: track fetch request history
//                    networkState.success(label: "fetched \(results.)")
                    removeAndInsertMRs(.reviewRequestedMergeRequests, account: account, results: results)
                }
            } catch {

            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
            let results: [MergeRequest] = ((try? await NetworkManager.shared.fetchAuthoredMergeRequests(with: account)) ?? []).map { mr in
                mr.account = account
                mr.type = .authoredMergeRequests
                return mr
            }
            removeAndInsertMRs(.authoredMergeRequests, account: account, results: results)
        }
    }

    private func removeAndInsertMRs(_ type: QueryType, account: Account, results: [MergeRequest]) {
//        let existing = account.mergeRequests.filter({ $0.type == type }).map({ $0.mergerequestID })
//        let updated = results.map { $0.mergerequestID }
//        let difference = existing.difference(from: updated)
//
//        for mergeRequest in account.mergeRequests {
//            if difference.contains(mergeRequest.mergerequestID) {
//                modelContext.delete(mergeRequest)
//            }
//        }

        DispatchQueue.main.async {
            for result in results {
                modelContext.insert(result)
            }
            try? modelContext.save()
        }
    }

    @MainActor
    private func fetchRepos() async {
        for account in accounts {
            let ids = mergeRequests.compactMap { mr in
                return mr.targetProject?.id.split(separator: "/").last
            }.compactMap({ Int($0) })

            let results = try? await NetworkManager.shared.fetchProjects(with: account, ids: Array(Set(ids)))

            // DispatchQueue due to SwiftData issues
            DispatchQueue.main.async {
                if let results {
                    for result in results {
                        withAnimation {
                            modelContext.insert(result)
                        }
                    }
                }
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    UserInterface()
        .modelContainer(.previews)
        .environmentObject(NoticeState())
}



//NotificationManager.shared.sendNotification(
//    title: title,
//    subtitle: "\(reference) is approved by \(approvers.formatted())",
//    userInfo: userInfo
//)
