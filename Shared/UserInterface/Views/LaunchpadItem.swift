//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI
import SwiftData

struct LaunchpadItem: View {
    var repo: LaunchpadRepo

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.modelContext) private var modelContext

    @State private var isHovering = false

    var body: some View {
            HStack {
                LaunchpadImage(repo: repo)

                VStack(alignment: .leading) {
                    Text(repo.name)
                    Text(repo.group)
                        .foregroundStyle(.secondary)
                }

                Button {
                    openURL(repo.url)
                    dismissWindow()
                } label: {
                    Label("Open on Web", systemImage: "arrow.up.forward")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.menubar)
            }
            .contextMenu {
                Button("Delete Repo Shortcut", systemImage: "delete.left", role: .destructive) {
                    withAnimation(.smooth) {
                        modelContext.delete(repo)
                    }
                }
            }
    }
}

#Preview {
    LaunchpadItem(repo: .preview)
        .scenePadding()
}
