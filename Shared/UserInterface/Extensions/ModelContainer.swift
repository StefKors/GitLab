//
//  ModelContainer.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import Foundation
import SwiftData

extension ModelContainer {
    static var previews: ModelContainer = {
        let schema = Schema([Account.self, UniversalMergeRequest.self, LaunchpadRepo.self])
        let modelConfiguration = ModelConfiguration("MergeRequests", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static var shared: ModelContainer = {
        let schema = Schema([Account.self, UniversalMergeRequest.self, LaunchpadRepo.self])
        let modelConfiguration = ModelConfiguration("MergeRequests", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
