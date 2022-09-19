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
}


public class LaunchpadState: ObservableObject {
    @Default(.contributedRepos) public var contributedRepos

    // Allow fetching Launchpad items at launch
    @Published var updatedAtLaunch: Bool = false

    func add(_ repo: LaunchpadRepo) {
        contributedRepos.insert(repo)
    }
}
