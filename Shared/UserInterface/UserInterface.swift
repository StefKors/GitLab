//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

enum NetworkState: String, Codable, CaseIterable, Identifiable {
    case fetching
    case idle
    var id: Self { self }
}

/// TODO: Show different accounts
/// TODO: Show different git providers (GL / GH)
/// TODO: Filter by type
/// TODO: show assigned issues
/// TODO: widget?
/// TODO: timeline view updates
struct UserInterface: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedView: QueryType = .authoredMergeRequests

    // var mergeRequests: [MergeRequest] {
    //     // switch selectedView {
    //     // case .authoredMergeRequests:
    //     //     return model.authoredMergeRequests
    //     // case .reviewRequestedMergeRequests:
    //     //     return model.reviewRequestedMergeRequests
    //     // }
    //     return []
    // }

    @Query private var mergeRequests: [MergeRequest]
    @Query private var accounts: [Account]
    @Query private var repos: [LaunchpadRepo]

    @State private var lastUpdate: Date? = nil
    @State private var networkState: NetworkState = .idle

    @State private var startDate: Date = .now

    var body: some View {
        TimelineView(.periodic(from: startDate, by: 12)) { context in
            //     AnalogTimerView(
            //         date: context.date,
            //         showSeconds: context.cadence <= .seconds)

            ZStack(alignment: .topTrailing) {
                LazyVStack(alignment: .center, spacing: 10) {
                    Text(context.date, format: .dateTime)
                    // Text(context.cadence )

                    // if network.apiToken.isEmpty {
                    //     BaseTextView(message: "No Token Found, Add Gitlab Token in Preferences")
                    // } else if network.tokenExpired {
                    //     BaseTextView(message: "Token Expired")
                    // } else {
                    Picker(selection: $selectedView, content: {
                        Text("Your Merge Requests").tag(QueryType.authoredMergeRequests)
                        Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
                    }, label: {
                        EmptyView()
                    }).pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 0)

                    LaunchpadView(repos: repos)

                    // Disabled in favor for real notifications`
                    NoticeListView()
                        .padding(.horizontal)

                    if mergeRequests.isEmpty {
                        BaseTextView(message: "All done 🥳")
                    }

                    VStack(alignment: .leading) {
                        List(mergeRequests) { mergeRequest in
                            MergeRequestRowView(MR: mergeRequest)
                                .padding(.bottom, 4)
                                .listRowSeparator(.visible)
                                .listRowSeparatorTint(Color.secondary.opacity(0.2))
                            // .id(mergeRequests[index].id)
                            // let isLast = index == mergeRequests.count - 1
                            // if !isLast {
                            // Divider()
                            // }
                        }
                        // .padding(.horizontal)
                        // .listStyle(.bordered)
                    }
                    // }
                    Text("\(lastUpdate?.debugDescription ?? "nil")")
                    LastUpdateMessageView(lastUpdate: $lastUpdate, networkState: $networkState)
                }
                .task(id: context.date) {
                    print("task: date update")
                }
                .task {
                    print("task: fetch")
                    // try? modelContext.delete(model: MergeRequest.self)
                    // print("OK DB cleared !")
                    await fetchReviewRequestedMRs()
                    await fetchAuthoredMRs()
                }
                // .onAppear {
                //     try? modelContext.delete(model: MergeRequest.self)
                //     print("OK Groups cleared !")
                // }
                // .task(id: networkState) {
                //     // await fetchReviewRequestedMRs()
                //     // await fetchAuthoredMRs()
                //     lastUpdate = .now
                //     networkState = .idle
                // }
                // .onAppear {
                //     Task(priority: .background) {
                //         await network.fetch()
                //     }
                // }
            }
            .frame(width: 500)
        }
    }

    // https://developer.apple.com/forums/thread/736008

    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            let results = try? await NetworkManager.shared.fetchReviewRequestedMergeRequests(with: account)
            if let results {
                for result in results {
                    withAnimation {
                        modelContext.insert(result)

                    }
                }
            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
            let results = try? await NetworkManager.shared.fetchAuthoredMergeRequests(with: account)
            if let results {
                for result in results {
                    withAnimation {
                        modelContext.insert(result)
                    }
                }
            }
        }
    }
}

// TODO: Setup swiftdata previews
// struct UserInterface_Previews: PreviewProvider {
//     static let networkManager = NetworkManager()
//     static var previews: some View {
//         UserInterface()
//             .environmentObject(self.networkManager)
//             .environmentObject(self.networkManager.noticeState)
//     }
// }
