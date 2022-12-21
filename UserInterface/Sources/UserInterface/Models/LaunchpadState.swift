//
//  RepoLaunchpadState.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//


import Foundation
import Defaults
import SwiftUI

public struct LaunchpadRepo: Codable, DefaultsSerializable, Equatable, Hashable  {
    public var id: String
    public var name: String
    public var image: Data?
    public var group: String = "Beam"
    public var url: URL

    public static func ==(lhs: LaunchpadRepo, rhs: LaunchpadRepo) -> Bool {
        return lhs.id == rhs.id
    }
}


public class LaunchpadState: ObservableObject {
    @Default(.contributedRepos) public var contributedRepos

    // Allow fetching Launchpad items at launch
    @Published var updateAtLaunch: Bool = true

    func upsert(_ repo: LaunchpadRepo) {
        guard updateAtLaunch else {
            print("skipping launchpad update for \(repo.name)")
            return
        }

        if let preExistingLaunchpad = contributedRepos.first(where: { contributedRepo in
            return contributedRepo.id == repo.id
        }) {
            contributedRepos.remove(preExistingLaunchpad)
        }

        contributedRepos.insert(repo)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            self.updateAtLaunch = false
        }
    }
}
