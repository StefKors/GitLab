//
//  ExtraWindow.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SharingGRDB

struct ExtraWindow: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()
    @FetchAll(UniversalMergeRequest.order(by: { $0.createdAt.desc() })) private var mergeRequests
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]
    @FetchAll(LaunchpadRepo.order(by: { $0.updatedAt.desc() })) private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests

    private var filteredMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.appearsActive) private var appearsActive
    @State private var hasLoaded: Bool = false

    var body: some View {
        VStack {
            Divider()
            MainContentView(
                repos: repos,
                filteredMergeRequests: filteredMergeRequests,
                accounts: accounts,
                withScrollView: true,
                selectedView: $selectedView
            )
        }
        .overlay(content: {
            Rectangle()
                .fill(.windowBackground)
                .opacity(appearsActive && hasLoaded ? 0 : 0.4)
                .allowsHitTesting(false)
                .task {
                    hasLoaded = true
                }
        })
        .environmentObject(self.noticeState)
        .environmentObject(self.networkState)
        .onOpenURL { url in
            openURL(url)
        }
        .toolbar {
            ToolbarItem {
                Picker(selection: $selectedView, content: {
                    Text("Merge Requests").tag(QueryType.authoredMergeRequests)
                    Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
                }, label: {
                    EmptyView()
                })
                .pickerStyle(.segmented)
            }
        }
    }
}
