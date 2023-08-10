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

struct LaunchpadRepo: Codable, Equatable, Hashable, Identifiable  {
    internal init(id: String, name: String, image: Data? = nil, group: String, url: URL, hasUpdatedSinceLaunch: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.group = group
        self.url = url
        self.hasUpdatedSinceLaunch = hasUpdatedSinceLaunch
    }
    
    var id: String
    var name: String
    var image: Data?
    var group: String
    var url: URL
    var hasUpdatedSinceLaunch: Bool = false
    
    static func ==(lhs: LaunchpadRepo, rhs: LaunchpadRepo) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case group
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<LaunchpadRepo.CodingKeys> = try decoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.name)
        self.image = try container.decodeIfPresent(Data.self, forKey: LaunchpadRepo.CodingKeys.image)
        self.group = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.group)
        if let url = try container.decodeURLWithEncodingIfPresent(forKey: LaunchpadRepo.CodingKeys.url) {
            self.url = url
        } else {
            self.url = try container.decode(URL.self, forKey: LaunchpadRepo.CodingKeys.url)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<LaunchpadRepo.CodingKeys> = encoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)
        
        try container.encode(self.id, forKey: LaunchpadRepo.CodingKeys.id)
        try container.encode(self.name, forKey: LaunchpadRepo.CodingKeys.name)
        try container.encodeIfPresent(self.image, forKey: LaunchpadRepo.CodingKeys.image)
        try container.encode(self.group, forKey: LaunchpadRepo.CodingKeys.group)
        try container.encode(self.url, forKey: LaunchpadRepo.CodingKeys.url)
    }
}

extension Store where Item == LaunchpadRepo {
    static let launchpadStore = Store<LaunchpadRepo>(
        storage: SQLiteStorageEngine.default(appendingPath: "LaunchpadRepos"),
        cacheIdentifier: \.id
    )
}

class LaunchpadController: ObservableObject {
    @Stored(in: .launchpadStore) var contributedRepos
    
    init(launchpads: Store<LaunchpadRepo> = .launchpadStore) {
        self._contributedRepos = Stored(in: launchpads)
    }
    
    func addRepo(repo: LaunchpadRepo) async {
        try? await self.$contributedRepos.insert(repo)
    }
    
    
    func removeRepo(repo: LaunchpadRepo) async {
        try? await self.$contributedRepos.remove(repo)
    }
    
    
    func clearAllRepos() async {
        try? await self.$contributedRepos.removeAll()
    }
    
}
