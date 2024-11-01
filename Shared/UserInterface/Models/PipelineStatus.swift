//
//  PipelineStatus.swift
//  GitLab
//
//  Created by Stef Kors on 01/11/2024.
//

import Foundation

// MARK: - PipelineStatus
enum PipelineStatus: String, Codable, Equatable {
    /// Pipeline has been created.
    case created = "CREATED"
    /// A resource (for example, a runner) that the pipeline requires to run is unavailable.
    case waitingForResource = "WAITING_FOR_RESOURCE"
    /// Pipeline is preparing to run.
    case preparing = "PREPARING"
    /// Pipeline has not started running yet.
    case pending = "PENDING"
    /// Pipeline is running.
    case running = "RUNNING"
    /// Custom status for when pipeline passes with success but a child job failed
    case warning = "WARNING"
    /// At least one stage of the pipeline failed.
    case failed = "FAILED"
    /// Pipeline completed successfully.
    case success = "SUCCESS"
    /// Pipeline was canceled before completion.
    case canceled = "CANCELED"
    /// Pipeline was skipped.
    case skipped = "SKIPPED"
    /// Pipeline needs to be manually started.
    case manual = "MANUAL"
    /// Pipeline is scheduled to run.
    case scheduled = "SCHEDULED"
    
    static func from(_ state: GitHub.CheckStatusState?) -> Self? {
        switch state {
        case .pending: return .pending
        case .queued: return .scheduled
        case .inProgress: return .running
        case .completed: return .success
        case .requested: return .created
        case .waiting: return .waitingForResource
        case .none: return nil
        }
    }
    
    static func from(_ state: GitHub.CheckConclusionState?) -> Self? {
        switch state {
        case .success: return .success
        case .failure: return .failed
        case .skipped: return .skipped
        case .actionRequired: return .manual
        case .timedOut: return .failed
        case .cancelled: return .canceled
        case .neutral: return .created
        case .stale: return .pending // I guess?
        case .startupFailure: return .failed
        case .none: return nil
        }
    }
}
