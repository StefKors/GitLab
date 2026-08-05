//
//  MainContentView.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI
import Get

struct MergeRequestRowModel: Identifiable, Equatable {
    let request: UniversalMergeRequest
    let account: Account?
    let titleText: String
    let requestURL: URL?
    let repoURL: URL?
    let branchSummary: String?
    let markdownLink: String?
    let provider: GitProvider?
    let instance: String?

    var id: String {
        request.id
    }

    init(request: UniversalMergeRequest, account: Account?) {
        let titleText = request.title ?? "untitled"
        let requestURL = request.url
        let sourceBranch = request.sourceBranch ?? request.pullRequest?.headRefName
        let targetBranch = request.targetBranch

        self.request = request
        self.account = account
        self.titleText = titleText
        self.requestURL = requestURL
        self.repoURL = request.repoUrl
        self.branchSummary = switch (sourceBranch, targetBranch) {
        case let (source?, target?):
            "\(source) -> \(target)"
        case let (source?, nil):
            source
        case let (nil, target?):
            target
        default:
            nil
        }
        self.markdownLink = requestURL.map { "[\(titleText)](\($0.absoluteString))" }
        self.provider = account?.provider
        self.instance = account?.instance
    }
}

struct LaunchpadItemModel: Identifiable, Equatable {
    let repo: LaunchpadRepo
    let displayName: String

    var id: String {
        repo.id
    }

    init(repo: LaunchpadRepo) {
        self.repo = repo
        if repo.group.isEmpty {
            self.displayName = repo.name
        } else {
            self.displayName = "\(repo.group)/\(repo.name)"
        }
    }
}

struct MainContentView: View {
    let launchpadItems: [LaunchpadItemModel]
    let rowModels: [MergeRequestRowModel]
    let hasAccounts: Bool
    var withScrollView: Bool = false
    var allowScrollBounce: Bool = true
    var maxHeight: CGFloat? = nil
    @Binding var activeRepoUrl: URL?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            LaunchpadSectionView(launchpadItems: launchpadItems, activeRepoUrl: $activeRepoUrl)
                .padding(6)

            Divider()

            // Disabled in favor for real notifications?
            NoticeListView()
                

            MergeRequestListContainer(
                rowModels: rowModels,
                hasAccounts: hasAccounts,
                withScrollView: withScrollView,
                allowScrollBounce: allowScrollBounce,
                maxHeight: maxHeight
            )

            LastUpdateMessageView()
        }
        .frame(maxHeight: 900, alignment: .top)
    }
}

private struct LaunchpadSectionView: View, Equatable {
    let launchpadItems: [LaunchpadItemModel]
    @Binding var activeRepoUrl: URL?

    static func == (lhs: LaunchpadSectionView, rhs: LaunchpadSectionView) -> Bool {
        lhs.launchpadItems == rhs.launchpadItems &&
            lhs.activeRepoUrl == rhs.activeRepoUrl
    }

    var body: some View {
        LaunchpadView(launchpadItems: launchpadItems, activeRepoUrl: $activeRepoUrl)
    }
}

private struct MergeRequestListContainer: View, Equatable {
    let rowModels: [MergeRequestRowModel]
    let hasAccounts: Bool
    let withScrollView: Bool
    let allowScrollBounce: Bool
    let maxHeight: CGFloat?

    static func == (lhs: MergeRequestListContainer, rhs: MergeRequestListContainer) -> Bool {
        lhs.rowModels == rhs.rowModels &&
            lhs.hasAccounts == rhs.hasAccounts &&
            lhs.withScrollView == rhs.withScrollView &&
            lhs.allowScrollBounce == rhs.allowScrollBounce &&
            lhs.maxHeight == rhs.maxHeight
    }

    var body: some View {
        if !hasAccounts {
            BaseTextView(message: "Setup your accounts in the settings")
        } else if rowModels.isEmpty {
            BaseTextView(message: "All done 🥳")
                .foregroundStyle(.secondary)
        } else {
            let listContent = PlainMergeRequestList(rowModels: rowModels)
                .padding(6)

            if withScrollView {
                let scrollView = ScrollView {
                    listContent
                }
                .frame(minHeight: 300, maxHeight: maxHeight)

                if allowScrollBounce {
                    scrollView.scrollBounceBehavior(.basedOnSize)
                } else {
                    scrollView
                }
            } else {
                listContent
            }
        }
    }
}

#Preview {
    MainContentView(
        launchpadItems: [.init(repo: .preview)],
        rowModels: [
            .init(request: .preview, account: .preview),
            .init(request: .preview2, account: .preview),
            .init(request: .preview3, account: .preview),
            .init(request: .preview4, account: .preview)
        ],
        hasAccounts: true,
        activeRepoUrl: .constant(nil)
    )
    .previewEnvironment()
}

#Preview("List - Full range of states") {
    MergeRequestListContainer(
        rowModels: [
            // GitLab: mixed pipeline, approvals & discussions
            .init(request: .preview, account: .preview),
            // GitLab: draft with failed test job
            .init(request: .preview2, account: .preview),
            // GitLab: draft, single stage without jobs
            .init(request: .preview3, account: .preview),
            // GitLab: merge train, all stages succeeded
            .init(request: .preview4, account: .preview),
            // GitLab: merge conflicts, failed pipeline with warning
            .init(request: .previewConflicts, account: .preview),
            // GitLab: approved, fully green pipeline
            .init(request: .previewAllSuccess, account: .preview),
            // GitLab: running towards manual deploy
            .init(request: .previewManualDeploy, account: .preview),
            // GitLab: no pipeline attached
            .init(request: .previewNoPipeline, account: .preview),
            // GitHub: PR with labels and status checks
            .init(request: .previewGitHub, account: .previewGitHub)
        ],
        hasAccounts: true,
        withScrollView: true,
        allowScrollBounce: true,
        maxHeight: 600
    )
    .previewEnvironment()
}

#Preview("List - All done") {
    MergeRequestListContainer(
        rowModels: [],
        hasAccounts: true,
        withScrollView: false,
        allowScrollBounce: true,
        maxHeight: nil
    )
    .previewEnvironment()
}

#Preview("List - No accounts") {
    MergeRequestListContainer(
        rowModels: [],
        hasAccounts: false,
        withScrollView: false,
        allowScrollBounce: true,
        maxHeight: nil
    )
    .previewEnvironment()
}
