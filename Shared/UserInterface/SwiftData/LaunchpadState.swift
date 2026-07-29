//
//  RepoLaunchpadState.swift
//
//
//  Created by Stef Kors on 16/09/2022.
//

import Foundation
import SwiftUI
import GRDB
import SQLiteData

@Table
struct LaunchpadRepo: FetchableRecord, Identifiable, Equatable, Codable, MutablePersistableRecord {
    var id: String
    var name: String
    var image: Data?
    
    @Column(as: URL?.JSONRepresentation.self)
    var imageURL: URL?
    
    var group: String
    
    @Column(as: URL.JSONRepresentation.self)
    var url: URL
    
    var createdAt: Date
    
    var updatedAt: Date
    
    @Column(as: GitProvider?.JSONRepresentation.self)
    var provider: GitProvider?
    
    var hasUpdatedSinceLaunch: Bool

    init(id: String, name: String, image: Data? = nil, imageURL: URL? = nil, group: String, url: URL, provider: GitProvider? = nil, hasUpdatedSinceLaunch: Bool = false, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.image = image
        self.imageURL = imageURL
        self.group = group
        self.url = url
        self.provider = provider
        self.hasUpdatedSinceLaunch = hasUpdatedSinceLaunch
        self.createdAt = Date.now
        self.updatedAt = updatedAt ?? Date.now
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
