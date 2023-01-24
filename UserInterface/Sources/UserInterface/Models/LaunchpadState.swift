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
    internal init(id: String, name: String, image: Data? = nil, group: String = "Beam", url: URL, hasUpdatedSinceLaunch: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.group = group
        self.url = url
        self.hasUpdatedSinceLaunch = hasUpdatedSinceLaunch
    }
    
    public var id: String
    public var name: String
    public var image: Data?
    public var group: String = "Beam"
    public var url: URL
    public var hasUpdatedSinceLaunch: Bool = false

    public static func ==(lhs: LaunchpadRepo, rhs: LaunchpadRepo) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case group
        case url
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<LaunchpadRepo.CodingKeys> = try decoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)

        self.id = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.name)
        self.image = try container.decodeIfPresent(Data.self, forKey: LaunchpadRepo.CodingKeys.image)
        self.group = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.group)
        self.url = try container.decode(URL.self, forKey: LaunchpadRepo.CodingKeys.url)

    }

    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<LaunchpadRepo.CodingKeys> = encoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)

        try container.encode(self.id, forKey: LaunchpadRepo.CodingKeys.id)
        try container.encode(self.name, forKey: LaunchpadRepo.CodingKeys.name)
        try container.encodeIfPresent(self.image, forKey: LaunchpadRepo.CodingKeys.image)
        try container.encode(self.group, forKey: LaunchpadRepo.CodingKeys.group)
        try container.encode(self.url, forKey: LaunchpadRepo.CodingKeys.url)
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
