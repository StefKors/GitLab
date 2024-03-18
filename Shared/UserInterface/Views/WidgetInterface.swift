//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData
//
//struct WidgetInterface: View {
//    // last update
//    var lastUpdate: Date?
//    var mergeRequests: [MergeRequest] = []
//    var accounts: [Account] = []
//    var repos: [LaunchpadRepo] = []
//
//    @State private var selectedView: QueryType = .reviewRequestedMergeRequests
//    @State private var timelineDate: Date = .now
//
//    var filteredMergeRequests: [MergeRequest] {
//        mergeRequests //.filter { $0.type == selectedView }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            VStack(alignment: .leading) {
//                if accounts.count > 1 {
//                    SectionedMergeRequestList(
//                        accounts: accounts,
//                        mergeRequests: filteredMergeRequests,
//                        selectedView: selectedView
//                    )
//                } else {
//                    PlainMergeRequestList(mergeRequests: filteredMergeRequests)
//                }
//            }
//
//            if let lastUpdate {
//                Text(lastUpdate.description)
//            }
//
//            Text("mergeRequests \(mergeRequests.count.description)")
//            Text("accounts \(accounts.count.description)")
//            Text("repos \(repos.count.description)")
//            if accounts.isEmpty {
//                BaseTextView(message: "Setup your accounts in the settings")
//            } else if filteredMergeRequests.isEmpty {
//
//                BaseTextView(message: "All done 🥳")
//                    .foregroundStyle(.secondary)
//            }
//
//
//        }.frame(alignment: .top)
//    }
//}
//
//#Preview {
//    WidgetInterface()
//}
