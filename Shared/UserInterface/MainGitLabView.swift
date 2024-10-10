//
//  MainGitLabView.swift
//  GitLab
//
//  Created by Stef Kors on 24/08/2023.
//

import SwiftUI
import SwiftData

struct MainGitLabView: View {
    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()

    var body: some View {
        UserInterface()
            .environmentObject(self.noticeState)
    }
}

#Preview {
    MainGitLabView()
}
