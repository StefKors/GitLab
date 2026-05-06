//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//
import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct MergeRequestRowView: View {
    let rowModel: MergeRequestRowModel

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var isHoveringRow: Bool = false

    var body: some View {
        Button {
            openLink(rowModel.requestURL)
        } label: {
            MergeRequestRowContent(rowModel: rowModel, isHoveringRow: isHoveringRow)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .contextMenu {
            if let requestURL = rowModel.requestURL {
                Button("Open Merge Request", systemImage: "arrow.up.forward") {
                    openLink(requestURL)
                }
            }
            
            if let repoURL = rowModel.repoURL {
                Button("Open Repository", systemImage: "folder") {
                    openLink(repoURL)
                }
            }
            
            Divider()
            
            Button("Copy Title", systemImage: "textformat") {
                copyToPasteboard(rowModel.titleText)
            }
            
            if let requestURL = rowModel.requestURL {
                Button("Copy Link", systemImage: "link") {
                    copyToPasteboard(requestURL.absoluteString)
                }
            }

            if let markdownLink = rowModel.markdownLink {
                Button("Copy Markdown Link", systemImage: "doc.on.doc") {
                    copyToPasteboard(markdownLink)
                }
            }

            if let branchSummary = rowModel.branchSummary {
                Button("Copy Branches", systemImage: "arrow.left.and.right") {
                    copyToPasteboard(branchSummary)
                }
            }

            if let repoURL = rowModel.repoURL {
                Button("Copy Repository URL", systemImage: "doc.on.doc") {
                    copyToPasteboard(repoURL.absoluteString)
                }
            }
        }
        .onHover { state in
            withAnimation(.snappy(duration: 0.18)) {
                isHoveringRow = state
            }
        }
    }
    
    private func openLink(_ url: URL?) {
        guard let url else { return }
        openURL(url)
        dismissWindow()
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

private struct MergeRequestRowContent: View, Equatable {
    let rowModel: MergeRequestRowModel
    let isHoveringRow: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            MRTitleView(linkText: rowModel.titleText, isDraft: rowModel.request.isDraft)
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
                .padding(.trailing)

            HorizontalMergeRequestSubRowView(
                request: rowModel.request,
                provider: rowModel.provider,
                account: rowModel.account,
                instance: rowModel.instance,
                isHoveringRow: isHoveringRow
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 50, content: {
        VStack(alignment: .leading, content: {
            MergeRequestRowView(rowModel: .init(request: .preview, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview3, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview2, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview4, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .previewGitHub, account: .previewGitHub))
        })
        .frame(width: 190)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(rowModel: .init(request: .preview, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview3, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview2, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview4, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .previewGitHub, account: .previewGitHub))
        })
        .frame(width: 290)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(rowModel: .init(request: .preview, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview3, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview2, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .preview4, account: .preview))
            MergeRequestRowView(rowModel: .init(request: .previewGitHub, account: .previewGitHub))
        })
    })
    .previewEnvironment()
    .scenePadding(.vertical)
    .scenePadding(.vertical)
}
