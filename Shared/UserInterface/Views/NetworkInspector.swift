//
//  NetworkInspector.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import SwiftUI

struct NetworkInspector: View {
    var ids = Set<NetworkEvent.ID>()
    var events: [NetworkEvent] = []

    var body: some View {
        ForEach(Array(ids), id: \.self) { id in

            if let event = events.first(where: { $0.id == id}) {

                GroupBox {
                    VStack {
                        Text(event.info.label)
                        Text(event.status?.description ?? "No status")
                        Text(event.timestamp.formatted(date: .omitted, time: .standard))
                        Text(event.response ?? "No response")
                    }
                }
            }
        }
    }
}
