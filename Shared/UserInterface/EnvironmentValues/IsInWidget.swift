//
//  IsInWidget.swift
//  GitLab
//
//  Created by Stef Kors on 25/04/2024.
//

import SwiftUI

private struct IsInWidgetKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True if current view is in Widget
    var isInWidget: Bool {
        get { self[IsInWidgetKey.self] }
        set { self[IsInWidgetKey.self] = newValue }
    }
}

extension View {
    func isInWidget(_ value: Bool) -> some View {
        environment(\.isInWidget, value)
    }
}
