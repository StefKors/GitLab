//
//  ExtraWindow.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SwiftData
import BackgroundFetcher

struct ExtraWindow: View {
    @Environment(\.openURL) private var openURL
    @Query(sort: \UniversalMergeRequest.createdAt, order: .reverse) private var mergeRequests: [UniversalMergeRequest]
    @Query private var accounts: [Account]
    @Query(sort: \LaunchpadRepo.createdAt, order: .reverse) private var repos: [LaunchpadRepo]

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

// A codable type that contains two numbers to add together.
struct CalculationRequest: Codable {
    let firstNumber: Int
    let secondNumber: Int
}

struct CalcuationResponse: Codable {
    let result: Int
}
