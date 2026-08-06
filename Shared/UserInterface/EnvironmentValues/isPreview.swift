//
//  isPreview.swift
//  GitLab
//
//  Created by Stef Kors on 25/04/2024.
//

import SwiftUI

private struct IsInWidgetKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    @Entry var isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
