//
//  PreviewEnvironmentView.swift
//  GitLab
//
//  Created by Stef Kors on 13/11/2024.
//

import SwiftUI

struct PreviewEnvironmentView: ViewModifier {
    var padding: Bool = true
    // Persisted state objects
    @StateObject private var settingsState = SettingsState()

    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()

    func body(content: Content) -> some View {
        content
            .environmentObject(noticeState)
            .environmentObject(networkState)
            .environmentObject(settingsState)
            .modelContainer(.shared)
            .if(padding) {
                $0.scenePadding()
            }
    }
}

extension View {
    func previewEnvironment() -> some View {
        modifier(PreviewEnvironmentView(padding: true))
    }
}
