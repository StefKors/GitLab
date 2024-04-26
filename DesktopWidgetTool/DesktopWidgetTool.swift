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



struct WidgetLaunchPadRow: View {
    let repos: [LaunchpadRepo]
    let length: Int
    var body: some View {
        HStack() {
            ForEach(repos.prefix(length), id: \.id) { repo in
                LaunchpadItem(repo: repo)
            }
        }
        .frame(alignment: .leading)
    }
}

#Preview {
    WidgetLaunchPadRow(repos: [], length: 4)
}

struct ExtraLargeWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits {
                WidgetLaunchPadRow(repos: repos, length: 10)
                WidgetLaunchPadRow(repos: repos, length: 9)
                WidgetLaunchPadRow(repos: repos, length: 8)
                WidgetLaunchPadRow(repos: repos, length: 7)
                WidgetLaunchPadRow(repos: repos, length: 6)
                WidgetLaunchPadRow(repos: repos, length: 5)
                WidgetLaunchPadRow(repos: repos, length: 4)
                WidgetLaunchPadRow(repos: repos, length: 3)
                WidgetLaunchPadRow(repos: repos, length: 2)
                WidgetLaunchPadRow(repos: repos, length: 1)
            }

            if accounts.count > 1 {
                SectionedMergeRequestList(
                    accounts: accounts,
                    mergeRequests: mergeRequests,
                    selectedView: selectedView
                )
            } else {
                PlainMergeRequestList(mergeRequests: mergeRequests)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(alignment: .top)
    }
}

struct LargeWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if accounts.count > 1 {
                SectionedMergeRequestList(
                    accounts: accounts,
                    mergeRequests: mergeRequests,
                    selectedView: selectedView
                )
            } else {
                PlainMergeRequestList(mergeRequests: mergeRequests)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(alignment: .top)
    }
}

struct MediumWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                Image(.mergeRequest).resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                Text(mergeRequests.count.description)
            }
            .font(.largeTitle)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(mergeRequests, id: \.id) { MR in
                    HStack(alignment: .top, spacing: 4) {
                        GitProviderView(provider: MR.account?.provider)
                            .frame(width: 18, height: 18, alignment: .center)

                        TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl, weight: .regular)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
        .frame(alignment: .top)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [.preview, .preview, .preview, .preview],
            accounts: [.preview],
            repos: [],
            selectedView: .authoredMergeRequests
        )
    }

    // TODO: demo data? or at placeholder?
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task { @MainActor in
            let now = Date.now
            let selectedView: QueryType = .authoredMergeRequests

            let context = ModelContainer.shared.mainContext

            let mergeRequests = (try? context.fetch(FetchDescriptor<MergeRequest>())) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>()))?.reversed() ?? []

            let entry =   SimpleEntry(
                date: now,
                mergeRequests: mergeRequests,
                accounts: accounts,
                repos: repos,
                selectedView: selectedView
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            var entries: [SimpleEntry] = []

            let now = Date.now
            let selectedView: QueryType = .authoredMergeRequests

            let context = ModelContainer.shared.mainContext

            let mergeRequests = (try? context.fetch(FetchDescriptor<MergeRequest>())) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>()))?.reversed() ?? []

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
                    mergeRequests: mergeRequests,
                    accounts: accounts,
                    repos: repos,
                    selectedView: selectedView
                )
            )

            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(5 * 60)))
            completion(timeline)
        }
    }


    private func fetchImages(_ mergeRequests: [MergeRequest]) -> [URL:Data] {
        var images: [URL: Data] = [:]
        for mr in mergeRequests {
            let approvers = mr.approvedBy?.edges?.compactMap({ $0.node }) ?? []
            for approver in approvers {

                // TODO: cache?
                if let url = approver.avatarUrl,
                   let data = try? Data(contentsOf: url) {
                    images[url] = data
                }
            }
        }

        return images
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mergeRequests: [MergeRequest]
    let accounts: [Account]
    let repos: [LaunchpadRepo]
    let selectedView: QueryType
}

struct GitLabDesktopWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemExtraLarge:
            ExtraLargeWidgetInterface(
                mergeRequests: entry.mergeRequests,
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemLarge:
            LargeWidgetInterface(
                mergeRequests: entry.mergeRequests,
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemMedium:
            MediumWidgetInterface(
                mergeRequests: entry.mergeRequests,
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        default:
            VStack {
                Text("default widget view")
            }
        }
    }
}

struct DesktopWidgetTool: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DesktopWidgetTool", provider: Provider()) { entry in
            GitLabDesktopWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Authored Merge Requests")
        .description("All your Authored Merge Requests directly visible.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

/// MacOS widget support for previews is non existent
#Preview("widget",
         as: .systemMedium,
         widget:{
    DesktopWidgetTool()
}) {
    Provider()
}
