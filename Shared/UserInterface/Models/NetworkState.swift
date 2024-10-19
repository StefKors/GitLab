//
//  NetworkState.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

class NetworkState: ObservableObject {
    @Published var events: [NetworkEvent] = []
    @Published var record: Bool = false

    func add(_ event: NetworkEvent) {
        if record {
            events.append(event)
        }
    }

    func update(_ newEvent: NetworkEvent) {
        if record {
            let newEvents = events.map { event in
                if event.identifier == newEvent.identifier {
                    return newEvent
                }
                return event
            }
            
            events = newEvents
        }
    }
}
