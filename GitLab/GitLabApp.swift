//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

// struct AnalogTimerView: View {
//     let date: Date
//     let showSeconds: Bool
//     var formatter: DateFormatter {
//         let formatter = DateFormatter()
//         formatter.dateFormat = "HH:mm:ss:SS"
//         return formatter
//     }
//     var body: some View {
//         Text(date, formatter: formatter)
//         // .font(.largeTitle)
//             .fontDesign(.monospaced)
//             .contentTransition(.numericText(value: date.timeIntervalSinceReferenceDate))
//             .animation(.bouncy(duration: 0.1), value: date)
//     }
// }

// TimelineView(.periodic(from: startDate, by: 0.01)) { context in
//     AnalogTimerView(
//         date: context.date,
//         showSeconds: context.cadence <= .seconds)
// }

@main
struct GitLabApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Account.self, MergeRequest.self, LaunchpadRepo.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Window("GitLab", id: "GitLab-Window") {
            MainGitLabView()
                .modelContainer(sharedModelContainer)
                .frame(width: 500)
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra(content: {
            MainGitLabView()
                .modelContainer(sharedModelContainer)
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image("Icon-Gradients-PNG")
            })
        })
//        .modelContainer(sharedModelContainer)
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
//        .modelContainer(sharedModelContainer)
    }
}
