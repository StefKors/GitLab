//
//  ContentView.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model: NetworkManager

    init(model: NetworkManager) {
        self._model = StateObject(wrappedValue: model)
    }


    @State var showSettings: Bool = false
    @State var isHovering: Bool = false

    @State var timeRemaining = 10
    let initialTimeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var dateValue: String? {
        guard let date = model.lastUpdate else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 10) {
                if model.apiToken.isEmpty || showSettings {
                    VStack(alignment: .leading) {
                        Text("GitLab API Token")
                        TextField(
                            "Enter token here...",
                            text: model.$apiToken,
                            onCommit: {
                                // make API call with token.
                                Task {
                                    await model.getMRs()
                                }
                            })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
                        Button("Clear API Token", action: {model.apiToken = ""})
                        Button("Query GitLab", action: {
                            Task {
                                await model.getMRs()
                            }
                        })
                    }
                } else {
                    ScrollView {
                        ForEach(model.mergeRequests, id: \.id) { MR in
                            VStack {
                                // MARK: - Top Part
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webURL)

                                        WebLink(
                                            linkText: "\(MR.targetProject?.path ?? "")\("/")\(MR.targetProject?.group?.fullPath ?? "")\(MR.reference ?? "")",
                                            destination: MR.targetProject?.webURL
                                        )
                                    }

                                    Spacer()
                                    VStack(alignment:.trailing) {
                                        HStack {

                                            if let count = MR.userDiscussionsCount, count > 1 {
                                                DiscussionCountIcon(count: count)
                                                Divider()
                                                    .padding(2)
                                            }

                                            let isApproved = MR.approved ?? false
                                            if isApproved {
                                                ApprovedReviewIcon()
                                            } else {
                                                // NeedsReviewIcon()
                                            }

                                            if let CIStatus = MR.headPipeline?.status {
                                                switch CIStatus {
                                                case .created:
                                                    CIProgressIcon()
                                                case .manual:
                                                    CiManualIcon()
                                                case .running:
                                                    CIProgressIcon()
                                                case .success:
                                                    CISuccessIcon()
                                                case .failed:
                                                    CIFailedIcon()
                                                case .canceled:
                                                    CICanceledIcon()
                                                case .skipped:
                                                    CISkippedIcon()
                                                }
                                            }

                                        }
                                    }
                                }
                            }
                            Divider()
                        }
                    }
                }
                HStack {
                    Spacer()

                    if let lastUpdate = dateValue {
                        let timeString = timeRemaining < 10 ? "0\(timeRemaining)" : "\(timeRemaining)"
                        let text = isHovering ? "\(timeString)s until next fetch" : "Last updated at: \(lastUpdate)"
                        Text(text)
                            .foregroundColor(.gray)
                            .font(.system(size: 10))
                            .onHover { hovering in
                                isHovering = hovering
                            }
                            .onReceive(timer) { _ in
                                let failedMRs = model.mergeRequests.filter({ $0.headPipeline?.status == .failed }).count
                                if failedMRs > 0 {
                                    NSApp.dockTile.badgeLabel = "\(failedMRs)"
                                } else {
                                    NSApp.dockTile.badgeLabel = nil
                                }

                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }

                                if timeRemaining <= 0 {
                                    timeRemaining = initialTimeRemaining
                                    Task(priority: .background) {
                                        await model.getMRs()
                                    }
                                }
                            }
                    }

                    Button(action: {
                        showSettings.toggle()
                    }, label: {
                        Image(systemName: "gear.circle.fill")
                    })
                }
            }
            .frame(maxWidth: 800, maxHeight: 300)
            .padding()
            .onAppear {
                Task {
                    await model.getMRs()
                }
            }
        }.frame(minWidth: 200, minHeight: 200)
            .contextMenu {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q", modifiers: [.command])
            }
    }
}
