//
//  GitLabDesktopWidget.swift
//  GitLabDesktopWidget
//
//  Created by Stef Kors on 19/08/2023.
//

import WidgetKit
import AppIntents
import SwiftData
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "Widgets", category: "GitLabDesktopProvider")

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀", count: 99, mergeRequests: fetchMRs())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀", count: 98, mergeRequests: fetchMRs())
        logger.info("getsnapshot of entry \(entry.count)")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of sixty entries an minute apart, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀", count: minuteOffset, mergeRequests: fetchMRs())
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    //
    private func fetchMRs() -> [MergeRequest] {
        let descriptor = FetchDescriptor<MergeRequest>()
        let modelContext = ModelContext(.shared)
        return try! modelContext.fetch(descriptor)
        
        //
        //     // // let tripName = trip.name
        //     // // descriptor.predicate = #Predicate { item in
        //     // //     item.title.contains(searchText) && tripName == item.trip?.name
        //     // // }
        //     let filteredList = try! modelContext.fetch(descriptor)
        //     logger.info("filteredList \(filteredList)")
        //     // fatalError("results: \(dump(filteredList))")
        //     return filteredList ?? []
//        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let count: Int
    let mergeRequests: [MergeRequest]
}


struct GitLabDesktopWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            MainGitLabView()
        }
    }
}

struct GitLabDesktopWidget: Widget {
    let kind: String = "GitLabDesktopWidget"
    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([Account.self, MergeRequest.self, LaunchpadRepo.self])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Text("bla")
//            if #available(macOS 14.0, *) {
//                GitLabDesktopWidgetEntryView(entry: entry)
//                    .containerBackground(.fill.tertiary, for: .widget)
//                    .modelContainer(sharedModelContainer)
//            } else {
//                GitLabDesktopWidgetEntryView(entry: entry)
//                    .padding()
//                    .background()
//                    .modelContainer(sharedModelContainer)
//            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
