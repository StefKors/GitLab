//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

public struct UserInterface: View {
    @StateObject public var model: NetworkManager

    public init(model: NetworkManager) {
        self._model = StateObject(wrappedValue: model)
    }


    @State public var showSettings: Bool = false
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

    public var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 10) {
                NotificationButton()
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
                        if model.mergeRequests.isEmpty {
                            InboxZeroIcon()
                        }
                        ForEach(model.mergeRequests.indices, id: \.self) { index in
                            MergeRequestRowView(MR: model.mergeRequests[index])
                                .id(model.mergeRequests[index].id)
                                .padding(.vertical, 4)
                            let isLast = index == model.mergeRequests.count - 1
                            if !isLast {
                                Divider()
                            }
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
#if os(macOS)
                                let failedMRs = model.mergeRequests.filter({ $0.headPipeline?.status == .failed }).count
                                if failedMRs > 0 {
                                    NSApp.dockTile.badgeLabel = "\(failedMRs)"
                                } else {
                                    NSApp.dockTile.badgeLabel = nil
                                }
#endif

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
            .padding()
            .onAppear {
                Task(priority: .background) {
                    await model.getMRs()
                }
            }
        }
#if os(macOS)
            .contextMenu {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q", modifiers: [.command])
            }
#endif
    }
}
