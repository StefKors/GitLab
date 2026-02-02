//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI
import SharingGRDB
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct LaunchpadItem: View {
    var repo: LaunchpadRepo
    @Binding var activeRepoUrl: URL?

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @Dependency(\.defaultDatabase) private var database

    private var isFiltered: Bool {
        activeRepoUrl == repo.url
    }

    var body: some View {
        HStack {
            Button {
                toggleFilter()
            } label: {
                HStack {
                    LaunchpadImage(repo: repo)

                    VStack(alignment: .leading) {
                        Text(repo.name)
                        Text(repo.group)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            Button {
                if isFiltered {
                    clearFilter()
                } else {
                    openURL(repo.url)
                    dismissWindow()
                }
            } label: {
                Label(isFiltered ? "Clear Filter" : "Open on Web", systemImage: isFiltered ? "xmark" : "arrow.up.forward")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.menubar)
        }
        .contextMenu {
            if isFiltered {
                Button("Clear Filter", systemImage: "xmark.circle") {
                    clearFilter()
                }
            } else {
                Button("Filter Merge Requests", systemImage: "line.3.horizontal.decrease.circle") {
                    setFilter()
                }
            }

            Divider()

            Button("Open Repository", systemImage: "arrow.up.forward") {
                openURL(repo.url)
                dismissWindow()
            }

            Button("Copy Repository URL", systemImage: "doc.on.doc") {
                copyToPasteboard(repo.url.absoluteString)
            }

            Button("Copy Repository Name", systemImage: "textformat") {
                copyToPasteboard(repoDisplayName)
            }

            Divider()

            Button("Remove Repo Shortcut", systemImage: "delete.left", role: .destructive) {
                if isFiltered {
                    clearFilter()
                }
                withAnimation(.smooth) {
                    Task {
                        try await database.write { db in
                            try repo.delete(db)
                        }
                    }
                }
            }
        }
    }

    private var repoDisplayName: String {
        if repo.group.isEmpty {
            return repo.name
        }

        return "\(repo.group)/\(repo.name)"
    }

    private func toggleFilter() {
        if isFiltered {
            clearFilter()
        } else {
            setFilter()
        }
    }

    private func setFilter() {
        withAnimation(.snappy(duration: 0.25)) {
            activeRepoUrl = repo.url
        }
    }

    private func clearFilter() {
        withAnimation(.snappy(duration: 0.25)) {
            activeRepoUrl = nil
        }
    }

    private func copyToPasteboard(_ value: String) {
#if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
#elseif canImport(UIKit)
        UIPasteboard.general.string = value
#endif
    }
}

#Preview {
    LaunchpadItem(repo: .preview, activeRepoUrl: .constant(nil))
        .scenePadding()
}
