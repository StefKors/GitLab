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

struct WidgetInterface: View {
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

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [],
            accounts: [],
            repos: [],
            selectedView: .authoredMergeRequests
        )
    }

    // TODO: demo data? or at placeholder?
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot")
        Task { @MainActor in
            print("getSnapshot is called")
            let now = Date.now
            let selectedView: QueryType = .authoredMergeRequests

            let context = ModelContainer.shared.mainContext
            let mergeRequests = (try? context.fetch(FetchDescriptor<MergeRequest>())) ?? []
            let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
            let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []

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
            print("getTimeline2 is called")
            let now = Date.now
            let selectedView: QueryType = .authoredMergeRequests

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
                    repos: repos,
                    selectedView: selectedView
                )
            )

            // Then display incomplted items
            //            entries.append(SimpleEntry(date: now.addingTimeInterval(0.5), items: incompleted))

            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

//let now = Date.now
//
//let context = ModelContainer.shared.mainContext
//let mergeRequests = (
//    try? context.fetch(
//        FetchDescriptor<MergeRequest>(predicate: #Predicate {
//            $0.type == type
//        })
//    )
//) ?? []
//let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
//let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []
//
//return SimpleEntry(
//    date: now,
//    mergeRequests: mergeRequests,
//    accounts: accounts,
//    repos: repos
//)

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mergeRequests: [MergeRequest]
    let accounts: [Account]
    let repos: [LaunchpadRepo]
    let selectedView: QueryType
}


struct GitLabDesktopWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetInterface(
            mergeRequests: entry.mergeRequests,
            accounts: entry.accounts,
            repos: entry.repos,
            selectedView: entry.selectedView
        )
    }
}

// Choose view based on widget family
//struct EmojiRangerWidgetEntryView: View {
//    var entry: SimpleEntry
//
//    @Environment(\.widgetFamily) var family
//
//    @ViewBuilder
//    var body: some View {
//        switch family {
//
//            // Code for other widget sizes.
//
//        case .systemLarge:
//            if #available(iOS 17.0, *) {
//                HStack(alignment: .top) {
//                    Button(intent: SuperCharge()) {
//                        Image(systemName: "bolt.fill")
//                    }
//                }
//                .tint(.white)
//                .padding()
//            }
//            // ...rest of view
//        }
//    }
//}

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
