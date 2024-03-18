//
//  DesktopWidgetTool.swift
//  DesktopWidgetTool
//
//  Created by Stef Kors on 06/03/2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct WidgetInterface: View {
    // last update
    var lastUpdate: Date?
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .reviewRequestedMergeRequests
    @State private var timelineDate: Date = .now

    var filteredMergeRequests: [MergeRequest] {
        mergeRequests //.filter { $0.type == selectedView }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
                if accounts.count > 1 {
                    SectionedMergeRequestList(
                        accounts: accounts,
                        mergeRequests: filteredMergeRequests,
                        selectedView: selectedView
                    )
                } else {
                    PlainMergeRequestList(mergeRequests: filteredMergeRequests)
                }

//            if let lastUpdate {
//                Text(lastUpdate.description)
//            }

//            Text("mergeRequests \(mergeRequests.count.description)")
//            Text("accounts \(accounts.count.description)")
//            Text("repos \(repos.count.description)")
//            if accounts.isEmpty {
//                BaseTextView(message: "Setup your accounts in the settings")
//            } else if filteredMergeRequests.isEmpty {
//                BaseTextView(message: "All done 🥳")
//                    .foregroundStyle(.secondary)
//            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(alignment: .top)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [],
            accounts: [],
            repos: []
        )
    }

    // TODO: demo data? or at placeholder?
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot")
        Task { @MainActor in
            print("getSnapshot is called")
            let now = Date.now

            let context = ModelContainer.shared.mainContext
            let mergeRequests = (try? context.fetch(FetchDescriptor<MergeRequest>())) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []

            let entry =   SimpleEntry(
                date: now,
                mergeRequests: mergeRequests,
                accounts: accounts,
                repos: repos
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            var entries: [SimpleEntry] = []
            print("getTimeline2 is called")
            let now = Date.now

            let context = ModelContainer.shared.mainContext
            //            @Query private var mergeRequests: [MergeRequest]
            //            @Query private var accounts: [Account]
            //            @Query private var repos: [LaunchpadRepo]
            let mergeRequests = (try? context.fetch(FetchDescriptor<MergeRequest>())) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []
            print("mergeRequests \(mergeRequests.count.description)")
            print("accounts \(accounts.count.description)")
            print("repos \(repos.count.description)")
            /// Used in Widget only.
            /// If we try to use the ``Item`` with ``@Model`` macro attached,
            /// the Xcode preview won't work as expected.
            //            struct SimpleItem {
            //            var id: String
            //            var text: String
            //            var completedDate: Date?
            //        }
            //            let simpleItems = items.map { SimpleItem(id: $0.id, text: $0.text, completedDate: $0.completedDate) }

            //            let recentlyCompletedOrIncompleted = simpleItems.filter { item in
            //                if let completedDate = item.completedDate {
            //                    return abs(completedDate.timeIntervalSince(now)) < 2
            //                } else {
            //                    return true
            //                }
            //            }
            //
            //            let incompleted = simpleItems.filter { $0.completedDate == nil }

            // First display items that are recently completed, which completedDate should within 2 seconds from now
            entries.append(
                SimpleEntry(
                    date: now,
                    mergeRequests: mergeRequests,
                    accounts: accounts,
                    repos: repos
                )
            )

            // Then display incomplted items
            //            entries.append(SimpleEntry(date: now.addingTimeInterval(0.5), items: incompleted))

            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mergeRequests: [MergeRequest]
    let accounts: [Account]
    let repos: [LaunchpadRepo]
}


struct GitLabDesktopWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetInterface(
            lastUpdate: entry.date,
            mergeRequests: entry.mergeRequests,
            accounts: entry.accounts,
            repos: entry.repos
        )
    }
}


struct DesktopWidgetTool: Widget {
    let kind: String = "DesktopWidgetTool"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GitLabDesktopWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
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
