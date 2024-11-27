//
//  NetworkStateView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct NetworkStateView: View {
    @EnvironmentObject private var networkState: NetworkState

    @State private var sortOrder = [KeyPathComparator(\NetworkEvent.timestamp,
                                                       order: .reverse)]

    @State private var events: [NetworkEvent] = []

    @State private var selectedEvents = Set<NetworkEvent.ID>()

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if networkState.record {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "pause.fill")
                            .foregroundStyle(.secondary)
                    }

                    Text("Network Events (\(events.count.description))")
                        .font(.headline)
                }
                .frame(alignment: .leading)
                Text("Events are only recorded when debug window is open.")
            }
            .padding(.vertical)
            .padding(.horizontal)

            Table(events, selection: $selectedEvents, sortOrder: $sortOrder) {
                TableColumn("") { event in
                    GitProviderView(provider: event.info.account.provider)
                        .frame(width: 18, height: 18, alignment: .center)
                }
                .width(max: 18)

                TableColumn("status") { event in
                    HStack {
                        if let status = event.status {
                            Text(Image(systemName: "circle.fill"))
                                .foregroundStyle(status == 200 ? .green : .red)
                            Text("\(status)")
                        } else {
                            ProgressView()
                                .progressViewStyle(.linear)
                        }
                    }
                    .frame(alignment: .leading)
                    .fontDesign(.monospaced)
                }
                .width(max: 50)

                TableColumn("time", value: \.timestamp) { event in
                    Text(event.timestamp.formatted(date: .omitted, time: .standard))
                        .fontDesign(.monospaced)
                }
                .width(max: 65)

                TableColumn("duration") { event in
                    Text(formatDuration(event.info.timestamp, event.timestamp))
                        .fontDesign(.monospaced)
                    //                    Text(event.info.timestamp..<event.timestamp.formatted(.timeDuration).description)
                }
                .width(min: 10, ideal: 60, max: 80)

                TableColumn("label") { event in
                    Text(event.info.label)
                }

                TableColumn("Response") { event in
                    if let response = event.response {
                        Text(response)
                    }
                }
            }
            .onChange(of: networkState.events, initial: true) { _, newEvents in
                events = newEvents.sorted(using: sortOrder)
            }
            .onChange(of: sortOrder) { _, sortOrder in
                events.sort(using: sortOrder)
            }

            NetworkInspector(ids: selectedEvents, events: events)
        }
        .padding(.bottom)
        .frame(minHeight: 300)
        .scrollBounceBehavior(.basedOnSize)
    }

    func formatDuration(_ dateA: Date, _ dateB: Date) -> String {
        return Duration
            .seconds(dateB.timeIntervalSince(dateA))
            .formatted(.units(
                allowed: [.minutes, .seconds, .milliseconds, .microseconds],
                width: .condensedAbbreviated
            ))
    }
}

#Preview("NetworkStateView - Recording") {
    NetworkStateView()
        .environmentObject(NetworkState.preview)
}

#Preview("NetworkStateView - Paused") {
    NetworkStateView()
        .environmentObject(NetworkState.previewPaused)
}
