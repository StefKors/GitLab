//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI
import SharingGRDB

struct LaunchpadItem: View {
    var repo: LaunchpadRepo

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @Dependency(\.defaultDatabase) private var database

    @State private var isHovering = false

    var body: some View {
            HStack {
                LaunchpadImage(repo: repo)

                VStack(alignment: .leading) {
                    Text(repo.name)
//                    Text(repo.group)
                    Text(repo.updatedAt, format: .dateTime)
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
//            .contextMenu {
//                Button("Delete Repo Shortcut", systemImage: "delete.left", role: .destructive) {
//                    withAnimation(.smooth) {
//                        Task {
//                            try await database.write { db in
//                                try repo.delete(db)
//                            }
//                        }
//                    }
//                }
//            }
    }
}

#Preview {
    LaunchpadItem(repo: .preview)
        .scenePadding()
}
