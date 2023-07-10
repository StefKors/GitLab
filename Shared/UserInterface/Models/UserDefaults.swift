//
//  File.swift
//  
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation
import Defaults

extension Defaults.Keys {
    // MARK: - NetworkManager
    static let authoredMergeRequests = Key<[MergeRequest]>("authoredMergeRequests", default: [])
    static let reviewRequestedMergeRequests = Key<[MergeRequest]>("reviewRequestedMergeRequests", default: [])
    static let targetProjectsDict = Key<[String: TargetProject]>("targetProjectsDict-9999999", default: [:])
}
