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
    let model: LaunchpadItemModel
    @Binding var activeRepoUrl: URL?

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @Dependency(\.defaultDatabase) private var database

    private var isFiltered: Bool {
        activeRepoUrl == model.repo.url
    }

    private var actionIconName: String {
        isFiltered ? "xmark" : "arrow.up.forward"
    }

    private var actionText: String {
        isFiltered ? "Clear Filter" : "Open on Web"
    }

    var body: some View {
        HStack {
            Button {
                toggleFilter()
            } label: {
                LaunchpadItemContent(model: model)
            }
            .buttonStyle(.plain)

            Button {
                if isFiltered {
                    clearFilter()
                } else {
                    openURL(model.repo.url)
                    dismissWindow()
                }
            } label: {
                SwiftUI.Label(actionText, systemImage: actionIconName)
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
                openURL(model.repo.url)
                dismissWindow()
            }

            Button("Copy Repository URL", systemImage: "doc.on.doc") {
                copyToPasteboard(model.repo.url.absoluteString)
            }

            Button("Copy Repository Name", systemImage: "textformat") {
                copyToPasteboard(model.displayName)
            }

            Divider()

            Button("Remove Repo Shortcut", systemImage: "delete.left", role: .destructive) {
                if isFiltered {
                    clearFilter()
                }
                _ = withAnimation(.smooth) {
                    Task {
                        try await database.write { db in
                            try model.repo.delete(db)
                        }
                    }
                }
            }
        }
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
            activeRepoUrl = model.repo.url
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

private struct LaunchpadItemContent: View, Equatable {
    let model: LaunchpadItemModel

    var body: some View {
        HStack(spacing: 8) {
            LaunchpadImage(repo: model.repo)

            VStack(alignment: .leading) {
                Text(model.repo.name)
                Text(model.repo.group)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LaunchpadItem(model: .init(repo: .preview), activeRepoUrl: .constant(nil))
        .scenePadding()
}
