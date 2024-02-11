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
        return mergeRequests.filter { $0.type == selectedView }
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
                    }).pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 0)

                    LaunchpadView(repos: repos)

                    // Disabled in favor for real notifications?
                    NoticeListView()
                        .padding(.horizontal)

                    VStack(alignment: .leading) {
                        List(filteredMergeRequests, id: \.id) { mergeRequest in
                            MergeRequestRowView(MR: mergeRequest)
                                .padding(.bottom, 4)
                                .listRowSeparator(.visible)
                                .listRowSeparatorTint(Color.secondary.opacity(0.2))
                        }
                        .animation(.snappy, value: filteredMergeRequests)
                    }

                    if accounts.isEmpty {
                        BaseTextView(message: "Setup your accounts in the settings")
                    } else if filteredMergeRequests.isEmpty {
                        BaseTextView(message: "All done 🥳")
                            .foregroundStyle(.secondary)
                    }

                    LastUpdateMessageView(lastUpdate: context.date, networkState: $networkState)
                }
                .task(id: context.date) {
                    print("task: date update & fetch")
                    await fetchReviewRequestedMRs()
                    await fetchAuthoredMRs()
                    await fetchRepos()
                }
                .frame(width: 500)
            }
        }
    }

    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            let results = try? await NetworkManager.shared.fetchReviewRequestedMergeRequests(with: account)
            if let results {
                for result in results {
                    withAnimation {
                        modelContext.insert(result)
                    }
                }
            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
            let results = try? await NetworkManager.shared.fetchAuthoredMergeRequests(with: account)
            if let results {
                for result in results {
                    withAnimation {
                        modelContext.insert(result)
                    }
                }
            }
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
