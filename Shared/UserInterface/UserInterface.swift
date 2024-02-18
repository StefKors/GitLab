//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

enum NetworkState: String, Codable, CaseIterable, Identifiable {
    case fetching
    case idle
    var id: Self { self }
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

    @State private var networkState: NetworkState = .idle
    @State private var selectedView: QueryType = .authoredMergeRequests

    @State private var timelineDate: Date = .now

    var filteredMergeRequests: [MergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    var body: some View {
        VStack {
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

                    VStack(alignment: .leading) {
                        if accounts.count > 1 {
                            SectionedMergeRequestList(
                                accounts: accounts,
                                mergeRequests: filteredMergeRequests,
                                selectedView: selectedView
                            )
                        } else {
                            PlainMergeRequestList(mergeRequests: filteredMergeRequests)
                        }
                    }
                    .padding(.horizontal)

                    if accounts.isEmpty {
                        BaseTextView(message: "Setup your accounts in the settings")
                    } else if filteredMergeRequests.isEmpty {
                        BaseTextView(message: "All done 🥳")
                            .foregroundStyle(.secondary)
                    }

                    LastUpdateMessageView(lastUpdate: context.date, networkState: $networkState)
                }
                .task(id: context.date) {
                    await fetchReviewRequestedMRs()
                    await fetchAuthoredMRs()
                    await fetchRepos()
                }
                .frame(idealWidth: 500, maxWidth: 500)
            }
        }
    }

    /// TODO: Cleanup and move both into the same function
    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            let results: [MergeRequest] = ((try? await NetworkManager.shared.fetchReviewRequestedMergeRequests(with: account)) ?? []).map { mr in
                mr.account = account
                mr.type = .reviewRequestedMergeRequests
                return mr
            }
            removeAndInsertMRs(.reviewRequestedMergeRequests, account: account, results: results)
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
        let existing = account.mergeRequests.filter({ $0.type == type }).map({ $0.mergerequestID })
        let updated = results.map { $0.mergerequestID }
        let difference = existing.difference(from: updated)

        for mergeRequest in account.mergeRequests {
            if difference.contains(mergeRequest.mergerequestID) {
                modelContext.delete(mergeRequest)
            }
        }

        for result in results {
            modelContext.insert(result)
        }
    }

    @MainActor
    private func fetchRepos() async {
        for account in accounts {
            let ids = mergeRequests.compactMap { mr in
                return mr.targetProject?.id.split(separator: "/").last
            }.compactMap({ Int($0) })

            let results = try? await NetworkManager.shared.fetchProjects(with: account, ids: Array(Set(ids)))

            if let results {
                for result in results {
                    withAnimation {
                        modelContext.insert(result)
                    }
                }
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
