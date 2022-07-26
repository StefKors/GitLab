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
    @State public var isHovering: Bool = false
    @State public var timeRemaining = 10
    public let initialTimeRemaining = 10
    public let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public var dateValue: String? {
        guard let date = model.lastUpdate else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    var mergeRequests: [MergeRequest] {
        switch selectedView {
        case .authoredMergeRequests:
            return model.authoredMergeRequests
        case .reviewRequestedMergeRequests:
            return model.reviewRequestedMergeRequests
        }
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .center, spacing: 10) {
                if model.apiToken.isEmpty {
                    HStack(alignment: .center) {
                        Text("No Token Found")
                    }
                    .frame(width: 200, height: 200)
                } else if model.tokenExpired {
                    HStack(alignment: .center) {
                        Text("Token Expired")
                    }
                    .frame(width: 200, height: 200)
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

                    // Show only last 3 notices's
                    NoticeListView()
                        .padding(.horizontal)

                    if mergeRequests.isEmpty {
                        InboxZeroIcon()
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
                HStack {
                    Spacer()

                    if let lastUpdate = dateValue {
                        Text("Last updated at: \(lastUpdate)")
                            .foregroundColor(.gray)
                            .font(.system(size: 10))
                            .onHover { hovering in
                                isHovering = hovering
                            }
                            .onReceive(timer) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }

                                if timeRemaining <= 0 {
                                    timeRemaining = initialTimeRemaining
                                    Task(priority: .background) {
                                        await model.fetch()
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom)
                .padding(.trailing)
            }
            .onAppear {
                Task(priority: .background) {
                    await model.fetch()
                }
            }
        }
        .frame(width: 550, alignment: .topLeading)
    }
}
