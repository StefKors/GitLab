//
//  String.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation

extension String {
    var isDraft: Bool {
        hasPrefix("WIP:") || hasPrefix("Draft:")
    }

    var removeDraft: String {
        replacingOccurrences(of: "WIP:", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "Draft:", with: "", options: [.anchored, .caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
