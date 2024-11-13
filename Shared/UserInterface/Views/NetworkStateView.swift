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
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(networkState.record ? .red : .secondary)
                    Text("Network Events")
                        .font(.headline)
                }
                Text("Events are only recorded when debug window is open.")
            }
            .padding(.vertical)

            Table(events, selection: $selectedEvents, sortOrder: $sortOrder) {
                TableColumn("status") { event in
                    HStack {
                        if let status = event.status {
                            Text("\(status)")
                        } else {
                            ProgressView()
                                .progressViewStyle(.linear)
                        }
                    }
                    .frame(width: 30)
                }
                .width(max: 40)

                TableColumn("timestamp", value: \.timestamp) { event in
                    Text(event.timestamp.formatted(date: .omitted, time: .standard))
                }
                .width(max: 80)

                TableColumn("duration") { event in
                    Text(formatDuration(event.info.timestamp, event.timestamp))
                    //                    Text(event.info.timestamp..<event.timestamp.formatted(.timeDuration).description)
                }
                .width(max: 60)

                TableColumn("label") { event in
                    Text(event.info.label)
                }

                TableColumn("Response") { event in
                    if let response = event.response {
                        Text(response)
                    }
                }
            }
            .onChange(of: networkState.events) { _, newEvents in
                events = newEvents.sorted(using: sortOrder)
            }
            .onChange(of: sortOrder) { _, sortOrder in
                events.sort(using: sortOrder)
            }

            NetworkInspector(ids: selectedEvents, events: events)
        }
        .padding(.bottom)
        .frame(minHeight: 300)
        .padding(.horizontal)
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

#Preview {
    NetworkStateView()
}
