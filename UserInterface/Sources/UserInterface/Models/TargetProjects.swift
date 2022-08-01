//
//  File.swift
//  
//
//  Created by Stef Kors on 27/07/2022.
//

import Foundation
import Defaults

// MARK: - GitLabQuery
public struct TargetProjectsQuery: Codable, DefaultsSerializable, Equatable {
    public let data: TargetProjectsDataClass?
}

// MARK: - TargetProjectsDataClass
public struct TargetProjectsDataClass: Codable, DefaultsSerializable, Equatable {
    public let projects: ProjectsEdges?
}

// MARK: - ProjectsEdges
public struct ProjectsEdges: Codable, DefaultsSerializable, Equatable {
    public let edges: [TargetProjectsEdge]?
}

// MARK: - TargetProjectsEdge
public struct TargetProjectsEdge: Codable, DefaultsSerializable, Equatable {
    public let node: TargetProject?
}
