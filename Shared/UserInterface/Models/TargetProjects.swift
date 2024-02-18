//
//  File.swift
//  
//
//  Created by Stef Kors on 27/07/2022.
//

import Foundation

// MARK: - GitLabQuery
struct TargetProjectsQuery: Codable, Equatable {
    let data: TargetProjectsDataClass?
}

// MARK: - TargetProjectsDataClass
struct TargetProjectsDataClass: Codable, Equatable {
    let projects: ProjectsEdges?
}

// MARK: - ProjectsEdges
struct ProjectsEdges: Codable, Equatable {
    let edges: [TargetProjectsEdge]?
}

// MARK: - TargetProjectsEdge
struct TargetProjectsEdge: Codable, Equatable {
    let node: TargetProject?
}
