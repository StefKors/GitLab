//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

public struct UserInterface: View {
    @EnvironmentObject public var model: NetworkManager

    public init() { }

    @State private var selectedView: QueryType = .authoredMergeRequests
    
    var mergeRequests: [MergeRequest] {
        switch selectedView {
        case .authoredMergeRequests:
            return model.authoredMergeRequests
        case .reviewRequestedMergeRequests:
            return model.reviewRequestedMergeRequests
        }
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 10) {
                if model.apiToken.isEmpty {
                    BaseTextView(message: "No Token Found, Add Gitlab Token in Preferences")
                } else if model.tokenExpired {
                    BaseTextView(message: "Token Expired")
                } else {
                    Picker(selection: $selectedView, content: {
                        Text("Your Merge Requests").tag(QueryType.authoredMergeRequests)
                        Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
                    }, label: {
                        EmptyView()
                    }).pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 0)

                    LaunchpadView(repos: model.launchpadState.contributedRepos)

                    // Disabled in favor for real notifications`
                    NoticeListView()
                        .padding(.horizontal)

                    if mergeRequests.isEmpty {
                        BaseTextView(message: "All done 🥳")
                    }
                    VStack(alignment: .leading) {
                        ForEach(mergeRequests.indices, id: \.self) { index in
                            MergeRequestRowView(MR: mergeRequests[index])
                                .id(mergeRequests[index].id)
                                .padding(.vertical, 4)
                            let isLast = index == mergeRequests.count - 1
                            if !isLast {
                                Divider()
                            }
                        }.padding(.horizontal)
                    }
                }
                LastUpdateMessageView()
            }
            .onAppear {
                Task(priority: .background) {
                    await model.fetch()
                }
            }
        }
        .frame(width: 500)
    }
}
