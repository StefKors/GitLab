//
//  DesktopWidgetTool.swift
//  DesktopWidgetTool
//
//  Created by Stef Kors on 06/03/2024.
//

import WidgetKit
import SwiftUI
import SwiftData

// Interactions & open link from widgets https://stackoverflow.com/a/77190038/3199999

struct Provider: TimelineProvider {
    var selectedView: QueryType

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [.preview, .preview, .preview, .preview],
            accounts: [.preview],
            repos: [],
            selectedView: .authoredMergeRequests
        )
    }

    init(selectedView: QueryType) {
        self.selectedView = selectedView
    }

    // TODO: demo data? or at placeholder?
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task { @MainActor in
            let now = Date.now

            let context = ModelContainer.shared.mainContext

            let mergeRequests = (
                try? context.fetch(
                    FetchDescriptor<UniversalMergeRequest>(
                        predicate: nil,
                        sortBy: [.init(\.createdAt, order: .reverse)]
                    )
                )
            ) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>()))?.reversed() ?? []

            let entry =   SimpleEntry(
                date: now,
                mergeRequests: mergeRequests, //Array(mergeRequests.prefix(5)),
                accounts: accounts,
                repos: repos,
                selectedView: selectedView
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task { @MainActor in
            var entries: [SimpleEntry] = []

            let now = Date.now

            let context = ModelContainer.shared.mainContext

            let mergeRequests = (
                try? context.fetch(
                    FetchDescriptor<UniversalMergeRequest>(
                        predicate: nil,
                        sortBy: [.init(\.createdAt, order: .reverse)]
                    )
                )
            ) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>()))?.reversed() ?? []

//            var moreRepos = repos
//            moreRepos.append(contentsOf: repos)
//            moreRepos.append(contentsOf: repos)
//            moreRepos.append(contentsOf: repos)
//            moreRepos.append(contentsOf: repos)
//            moreRepos.append(contentsOf: repos)

            //let mergeRequests = (
            //    try? context.fetch(
            //        FetchDescriptor<MergeRequest>(predicate: #Predicate {
            //            $0.type == type
            //        })
            //    )
            //) ?? []

            entries.append(
                SimpleEntry(
                    date: now,
                    mergeRequests: mergeRequests, //Array(mergeRequests.prefix(5)),
                    accounts: accounts,
                    repos: repos,
                    selectedView: selectedView
                )
            )

//            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(5 * 60)))
//            let timeline = Timeline(entries: entries, policy: .never)
            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(30)))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mergeRequests: [UniversalMergeRequest]
    let accounts: [Account]
    let repos: [LaunchpadRepo]
    let selectedView: QueryType
}

extension SimpleEntry {
    static let preview = SimpleEntry(
        date: .distantFuture,
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}

struct AuthoredMergeRequestWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AuthoredMergeRequestWidget", provider: Provider(selectedView: .authoredMergeRequests)) { entry in
            MergeRequestWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Authored Merge Requests")
        .description("All your Authored Merge Requests directly visible.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct ReviewRequestedMergeRequestWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ReviewRequestedMergeRequestWidget", provider: Provider(selectedView: .reviewRequestedMergeRequests)) { entry in
            MergeRequestWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Review Requested Merge Requests")
        .description("Merge Requests you should review.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}


struct LaunchPadWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LaunchpadWidget", provider: Provider(selectedView: .authoredMergeRequests)) { entry in
            LaunchPadWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Repo Launchpad")
        .description("Quick access to your recently used Repositories")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

