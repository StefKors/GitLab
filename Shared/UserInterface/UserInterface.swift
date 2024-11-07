//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData
import Get

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

    @Query private var accounts: [Account]
    @Query(
        sort: \LaunchpadRepo.createdAt,
        order: .reverse
    ) private var repos: [LaunchpadRepo]
    @Query(
        sort: \UniversalMergeRequest.createdAt,
        order: .reverse
    ) private var mergeRequests: [UniversalMergeRequest]

    @State private var selectedView: QueryType = .authoredMergeRequests

    @State private var timelineDate: Date = .now

    private var filteredMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker(selection: $selectedView, content: {
                Text("Your Merge Requests").tag(QueryType.authoredMergeRequests)
                Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
#if DEBUG
                Text("Debug").tag(QueryType.networkDebug)
#endif
            }, label: {
                EmptyView()
            })
            .pickerStyle(.segmented)
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 0)

            if selectedView == .networkDebug {
                NetworkStateView()
            } else {
                MainContentView(
                    repos: repos,
                    filteredMergeRequests: filteredMergeRequests,
                    accounts: accounts,
                    selectedView: $selectedView
                )
                .task(id: filteredMergeRequests) {
                    print("filteredMergeRequests updated")
                }
            }
        }

        .frame(maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
//        .task(id: "once") {
//            Task {
//                await fetchReviewRequestedMRs()
//                await fetchAuthoredMRs()
//                await fetchRepos()
//                await branchPushes()
//            }
//        }
//        .onReceive(timer) { _ in
//            timelineDate = .now
//            Task {
//                await fetchReviewRequestedMRs()
//                await fetchAuthoredMRs()
//                await fetchRepos()
//                await branchPushes()
//            }
//        }
    }
}

#Preview {
    HStack(alignment: .top) {
        UserInterface()
            .modelContainer(.previews)
            .frame(maxHeight: .infinity, alignment: .top)
            .scenePadding()
    }
    .scenePadding()
}

// NotificationManager.shared.sendNotification(
//    title: title,
//    subtitle: "\(reference) is approved by \(approvers.formatted())",
//    userInfo: userInfo
// )
