//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

struct ExtraWindow: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()
    @Query private var mergeRequests: [MergeRequest]
    @Query private var accounts: [Account]
    @Query private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests

    private var filteredMergeRequests: [MergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

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
        .environmentObject(self.noticeState)
        .environmentObject(self.networkState)
        .onOpenURL { url in
            openURL(url)
        }
        .toolbar {
            ToolbarItem() {
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


//
//#Preview {
//    ExtraWindow()
//}

@main
struct GitLabApp: App {
    var sharedModelContainer: ModelContainer = .shared

    @Environment(\.openURL) var openURL

    @State var receivedURL: URL? = nil

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var searchText: String = ""

    var body: some Scene {
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
                .modelContainer(sharedModelContainer)
                .navigationTitle("GitLab")
                .presentedWindowBackgroundStyle(.translucent)
//                .presentedWindowBackgroundStyle(.)
//                .navigationSubtitle("Merge requests")
//                .searchable(text: $searchText)
        }
//        .windowStyle(.automatic)
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)

        MenuBarExtra(content: {

            MainGitLabView()
                .modelContainer(sharedModelContainer)
                .frame(width: 600)
                .onOpenURL { url in
                    openURL(url)
                }
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image(.iconGradientsPNG)
            })
        })
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)


        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}
