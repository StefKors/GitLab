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
    @StateObject var networkManager = NetworkManager()

    let container = try! ModelContainer(for: [Account.self, MergeRequest.self])

    var body: some Scene {
        MenuBarExtra(content: {
            MenubarContentView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
                .modelContainer(container)
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image("Icon-Gradients-PNG")
            })
        })

        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
        .modelContainer(container)
    }
}
