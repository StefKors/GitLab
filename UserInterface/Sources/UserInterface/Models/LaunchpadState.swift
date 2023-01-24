//
//  RepoLaunchpadState.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//


import Foundation
import Defaults
import SwiftUI
import Boutique

public struct LaunchpadRepo: Codable, Equatable, Hashable, Identifiable  {
    public var id: String
    public var name: String
    public var image: Data?
    public var group: String = "Beam"
    public var url: URL

    public static func ==(lhs: LaunchpadRepo, rhs: LaunchpadRepo) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension Store where Item == LaunchpadRepo {
    static let launchpadStore = Store<LaunchpadRepo>(
        storage: SQLiteStorageEngine.default(appendingPath: "LaunchpadRepos")
    )
}

public class LaunchpadController: ObservableObject {
    @Stored(in: .launchpadStore) var contributedRepos

    func addRepo(repo: LaunchpadRepo) async {
        // Make an API call that adds the note to the server...
        try? await self.$contributedRepos.insert(repo)
    }


    func removeRepo(repo: LaunchpadRepo) async {
        // Make an API call that removes the repo from the server...
        try? await self.$contributedRepos.remove(repo)
    }


    func clearAllRepos() async {
        // Make an API call that removes all the notes from the server...
        try? await self.$contributedRepos.removeAll()
    }

}
