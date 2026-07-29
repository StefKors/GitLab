//
//  ExtraWindow.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SQLiteData

struct ExtraWindow: View {
    @Environment(\.openURL) private var openURL
    @FetchAll(UniversalMergeRequest.order(by: { $0.createdAt.desc() })) private var mergeRequests
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]
    @FetchAll(LaunchpadRepo.order(by: { $0.updatedAt.desc() })) private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests
    @State private var activeRepoUrl: URL?

    private var filteredMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    private var accountByID: [Account.ID: Account] {
        Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) })
    }

    private var rowModels: [MergeRequestRowModel] {
        filteredMergeRequests.map { request in
            MergeRequestRowModel(request: request, account: accountByID[request.accountsId])
        }
    }

    private var launchpadItems: [LaunchpadItemModel] {
        repos.map(LaunchpadItemModel.init)
    }

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.appearsActive) private var appearsActive
    @State private var hasLoaded: Bool = false

    var body: some View {
        VStack {
            Divider()
            MainContentView(
                launchpadItems: launchpadItems,
                rowModels: rowModels,
                hasAccounts: !accounts.isEmpty,
                withScrollView: true,
                activeRepoUrl: $activeRepoUrl
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
