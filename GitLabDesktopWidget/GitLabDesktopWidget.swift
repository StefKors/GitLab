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

struct GitLabWidgetEntry: TimelineEntry {
    var date: Date
    var snapshot: GitLabSnapshot?

    static var empty: Self {
        Self(date: .now)
    }
}

struct GitLabSnapshot {
    let mergeRequests: [MergeRequest]
    let accounts: [Account]
}


struct GitLabSnapshotTimelineProvider: AppIntentTimelineProvider {
    let modelContext = ModelContext(.shared)

    init() {
//        DataGeneration.generateAllData(modelContext: modelContext)
    }

    func mergeRequests(for configuration: GitLabWidgetIntent) -> [MergeRequest] {
        try! modelContext.fetch(FetchDescriptor<MergeRequest>())
//        if let id = configuration.specificBackyard?.id {
//            try! modelContext.fetch(
//                FetchDescriptor<Backyard>(predicate: #Predicate { $0.id == id })
//            )
//        } else if configuration.backyards == .favorites {
//            try! modelContext.fetch(
//                FetchDescriptor<Backyard>(predicate: #Predicate { $0.isFavorite == true })
//            )
//        } else {
//            try! modelContext.fetch(FetchDescriptor<Backyard>())
//        }
    }

    func placeholder(in context: Context) -> MergeRequestWidgetEntry {
        let backyard = try! modelContext.fetch(FetchDescriptor<Backyard>(sortBy: [.init(\.creationDate)])).first!
        return BackyardWidgetEntry(
            date: .now,
            snapshot: BackyardSnapshot(
                backyard: backyard,
                visitingBird: nil,
                timeInterval: backyard.timeIntervalOffset,
                date: .now,
                notableEvents: []
            )
        )
    }

    func snapshot(for configuration: BackyardWidgetIntent, in context: Context) async -> BackyardWidgetEntry {
        logger.info("Finding backyards for widget snapshot, intent: \(String(configuration.backyards.rawValue))")
        let backyards = backyards(for: configuration)
        logger.info("Found \(backyards.count) backyards")
        guard let backyard = backyards.first else {
            return .empty
        }

        let snapshot = backyard.snapshots(through: .now, total: 1).first!
        return BackyardWidgetEntry(date: snapshot.date, snapshot: snapshot)
    }

    func timeline(for configuration: BackyardWidgetIntent, in context: Context) async -> Timeline<BackyardWidgetEntry> {
        logger.info("Finding backyards for widget timeline, intent: \(String(configuration.backyards.rawValue))")
        let backyards = backyards(for: configuration)
        logger.info("Found \(backyards.count) backyards")
        guard let backyard = backyards.first else {
            return Timeline(
                entries: [.empty],
                policy: .never
            )
        }

        let snapshots = backyard.snapshots(through: .init(timeIntervalSinceNow: 60 * 60 * 36)).map {
            BackyardWidgetEntry(date: $0.date, snapshot: $0)
        }
        return Timeline(entries: snapshots, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<BackyardWidgetIntent>] {
        [
            AppIntentRecommendation(intent: BackyardWidgetIntent(backyards: .all), description: "All Backyards"),
            AppIntentRecommendation(intent: BackyardWidgetIntent(backyards: .favorites), description: "Favorite Backyards")
        ]
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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Account.self, MergeRequest.self, LaunchpadRepo.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
//        AppIntentConfiguration(
//            kind: kind,
//            intent: GitLabWidgetIntent.self,
//            provider: GitLabSnapshotTimelineProvider()
//        ) { entry in
//            GitLabWidgetView(entry: entry)
//        }
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
    }
}

struct MergeRequestEntity: AppEntity, Identifiable, Hashable {
    var id: MergeRequest.ID
    var title: String?

    init(id: MergeRequest.ID, title: String) {
        self.id = id
        self.title = title
    }

    init(from mergeRequest: MergeRequest) {
        self.id = mergeRequest.id
        self.title = mergeRequest.title
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title ?? "")")
    }

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Backyard")
    static var defaultQuery = MergeRequestEntityQuery()
}

struct MergeRequestEntityQuery: EntityQuery, Sendable {
    func entities(for identifiers: [MergeRequest.ID]) async throws -> [MergeRequestEntity] {
        logger.info("Loading backyards for identifiers: \(identifiers)")
        let modelContext = ModelContext(.shared)
        let mergeRequests = try! modelContext.fetch(FetchDescriptor<MergeRequest>())
        logger.info("Found \(mergeRequests.count) mergeRequests")
        return mergeRequests.map { MergeRequestEntity(from: $0) }
    }

    func entities() async throws -> [MergeRequestEntity] {
        let modelContext = ModelContext(.shared)
        let mergeRequests = try! modelContext.fetch(FetchDescriptor<MergeRequest>())
        logger.info("Found \(mergeRequests.count) mergeRequests")
        return mergeRequests.map { MergeRequestEntity(from: $0) }
    }
}

struct GitLabWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Backyard"
    static let description = IntentDescription("Keep track of your backyards.")

    @Parameter(title: "MergeRequests", default: GitLabWidgetContent.all)
    var mergeRequests: GitLabWidgetContent

    init(mergeRequests: GitLabWidgetContent = .all, specificBackyard: MergeRequestEntity? = nil) {
        self.mergeRequests = mergeRequests
    }

    init() {
    }

    static var parameterSummary: some ParameterSummary {
        When(\.$mergeRequests, .equalTo, GitLabWidgetContent.authored) {
            Summary {
                \.$mergeRequests
            }
        } otherwise: {
            Summary {
                \.$mergeRequests
            }
        }
    }
}

enum GitLabWidgetContent: String, AppEnum {
    case all
    case authored
    case reviewRequested

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Merge Request List")

    static let caseDisplayRepresentations: [GitLabWidgetContent: DisplayRepresentation] = [
        .all: DisplayRepresentation(
            title: LocalizedStringResource(
                "All",
                comment: "All Merge Requests"
            )
        ),
        .authored: DisplayRepresentation(
            title: LocalizedStringResource(
                "Authored",
                comment: "Merge Requests authored by you."
            )
        ),
        .reviewRequested: DisplayRepresentation(
            title: LocalizedStringResource(
                "Review Requested",
                comment: "Merge Requests that are assigned to you to review."
            )
        )
    ]
}
