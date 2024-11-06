//
//  RepoLaunchpadState.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import Foundation
import SwiftUI
import SwiftData

@Model final class LaunchpadRepo: Codable, Equatable, Hashable, Identifiable {
    init(id: String, name: String, image: Data? = nil, imageURL: URL? = nil, group: String, url: URL, provider: GitProvider? = nil, hasUpdatedSinceLaunch: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.imageURL = imageURL
        self.group = group
        self.url = url
        self.provider = provider
        self.hasUpdatedSinceLaunch = hasUpdatedSinceLaunch
    }

    @Attribute(.unique) var id: String
    var name: String
    var image: Data?
    var imageURL: URL?
    var group: String
    var url: URL
    var createdAt: Date = Date.now
    var provider: GitProvider?
    var hasUpdatedSinceLaunch: Bool

    static func == (lhs: LaunchpadRepo, rhs: LaunchpadRepo) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case imageURL
        case group
        case url
        case createdAt
        case provider
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<LaunchpadRepo.CodingKeys> = try decoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)

        self.id = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.name)
        self.image = try container.decodeIfPresent(Data.self, forKey: LaunchpadRepo.CodingKeys.image)
        self.imageURL = try container.decodeIfPresent(URL.self, forKey: LaunchpadRepo.CodingKeys.imageURL)
        self.group = try container.decode(String.self, forKey: LaunchpadRepo.CodingKeys.group)
//        if let url = try container.decodeURLWithEncodingIfPresent(forKey: LaunchpadRepo.CodingKeys.url) {
//            self.url = url
//        } else {
//            self.url = try container.decode(URL.self, forKey: LaunchpadRepo.CodingKeys.url)
//        }
        self.url = try container.decode(URL.self, forKey: LaunchpadRepo.CodingKeys.url)
        self.createdAt = try container.decode(Date.self, forKey: LaunchpadRepo.CodingKeys.createdAt)
        self.provider = try container.decodeIfPresent(GitProvider.self, forKey: LaunchpadRepo.CodingKeys.provider)
        self.hasUpdatedSinceLaunch = false
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<LaunchpadRepo.CodingKeys> = encoder.container(keyedBy: LaunchpadRepo.CodingKeys.self)

        try container.encode(self.id, forKey: LaunchpadRepo.CodingKeys.id)
        try container.encode(self.name, forKey: LaunchpadRepo.CodingKeys.name)
        try container.encodeIfPresent(self.image, forKey: LaunchpadRepo.CodingKeys.image)
        try container.encodeIfPresent(self.imageURL, forKey: LaunchpadRepo.CodingKeys.imageURL)
        try container.encode(self.group, forKey: LaunchpadRepo.CodingKeys.group)
        try container.encode(self.url, forKey: LaunchpadRepo.CodingKeys.url)
        try container.encode(self.createdAt, forKey: LaunchpadRepo.CodingKeys.createdAt)
        try container.encodeIfPresent(self.provider, forKey: LaunchpadRepo.CodingKeys.provider)
    }

    static let preview = LaunchpadRepo(
        id: "uuid",
        name: "GitLab",
        image: .previewRepoImage,
        group: "StefKors",
        url: URL(string: "https://gitlab.com/stefkors/swiftui-launchpad")!,
        hasUpdatedSinceLaunch: false
    )

    static let preview2 = LaunchpadRepo(
        id: "uuid-1",
        name: "SwiftUI Launchpad",
        image: nil,
        group: "StefKors",
        url: URL(string: "https://gitlab.com/stefkors/swiftui-launchpad")!,
        hasUpdatedSinceLaunch: false
    )

    static let preview3 = LaunchpadRepo(
        id: "uuid-2",
        name: "React",
        image: nil,
        group: "StefKors",
        url: URL(string: "https://gitlab.com/stefkors/swiftui-launchpad")!,
        hasUpdatedSinceLaunch: false
    )
}
