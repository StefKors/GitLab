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

extension EnvironmentValues {
    @Entry var isHoveringRow: Bool = false
}

struct MergeRequestRowView: View {
    var request: UniversalMergeRequest

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var isHoveringRow: Bool = false
    
    private var titleText: String {
        request.title ?? "untitled"
    }
    
    private var requestUrl: URL? {
        request.url
    }
    
    private var repoUrl: URL? {
        request.repoUrl
    }
    
    private var sourceBranch: String? {
        request.sourceBranch ?? request.pullRequest?.headRefName
    }
    
    private var targetBranch: String? {
        request.targetBranch
    }
    
    private var branchSummary: String? {
        switch (sourceBranch, targetBranch) {
        case let (source?, target?):
            return "\(source) -> \(target)"
        case let (source?, nil):
            return source
        case let (nil, target?):
            return target
        default:
            return nil
        }
    }
    
    private var markdownLink: String? {
        guard let requestUrl else { return nil }
        return "[\(titleText)](\(requestUrl.absoluteString))"
    }

    var body: some View {
        Button {
            openLink(requestUrl)
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                MRTitleView(linkText: titleText, isDraft: request.isDraft)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                    .padding(.trailing)

                HorizontalMergeRequestSubRowView(request: request)
            }
            .environment(\.isHoveringRow, isHoveringRow)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .contextMenu {
            if let requestUrl {
                Button("Open Merge Request", systemImage: "arrow.up.forward") {
                    openLink(requestUrl)
                }
            }
            
            if let repoUrl {
                Button("Open Repository", systemImage: "folder") {
                    openLink(repoUrl)
                }
            }
            
            Divider()
            
            Button("Copy Title", systemImage: "textformat") {
                copyToPasteboard(titleText)
            }
            
            if let requestUrl {
                Button("Copy Link", systemImage: "link") {
                    copyToPasteboard(requestUrl.absoluteString)
                }
            }

            if let markdownLink {
                Button("Copy Markdown Link", systemImage: "doc.on.doc") {
                    copyToPasteboard(markdownLink)
                }
            }

            if let branchSummary {
                Button("Copy Branches", systemImage: "arrow.left.and.right") {
                    copyToPasteboard(branchSummary)
                }
            }

            if let repoUrl {
                Button("Copy Repository URL", systemImage: "doc.on.doc") {
                    copyToPasteboard(repoUrl.absoluteString)
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

#Preview {
    VStack(alignment: .leading, spacing: 50, content: {
        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
            MergeRequestRowView(request: .preview4)
            MergeRequestRowView(request: .previewGitHub)
        })
        .frame(width: 190)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
            MergeRequestRowView(request: .preview4)
            MergeRequestRowView(request: .previewGitHub)
        })
        .frame(width: 290)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
            MergeRequestRowView(request: .preview4)
            MergeRequestRowView(request: .previewGitHub)
        })
    })
    .previewEnvironment()
    .scenePadding(.vertical)
    .scenePadding(.vertical)
}
