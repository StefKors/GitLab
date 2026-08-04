//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SQLiteData
import Get
import WidgetKit
import os
#if os(macOS)
import AppKit
#endif

/// Backlog tickets:
/// - UI-101: multi-account switcher and provider filter (GitLab/GitHub)
/// - UI-102: assigned issues tab and query pipeline
/// - UI-103: split provider-specific networking from UI orchestration
struct UserInterface: View {
    @Dependency(\.defaultDatabase) private var database
//    @SharedReader(.fetchAll(sql: "SELECT * FROM universal_merge_requests ORDER BY datetime(createdAt) DESC")) private var mergeRequests: [UniversalMergeRequest]

    @FetchAll(UniversalMergeRequest.order(by: { $0.createdAt.desc() })) private var mergeRequests
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]
    @FetchAll(LaunchpadRepo.order(by: { $0.updatedAt.desc() })) private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests
    @State private var activeRepoUrl: URL?

    @State private var timelineDate: Date = .now
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    private let perfLog = OSLog(subsystem: "com.stefkors.gitlab", category: "performance")
    private let logger = Logger(subsystem: "com.stefkors.gitlab", category: "UserInterface")

    @EnvironmentObject private var noticeState: NoticeState
    @EnvironmentObject private var networkState: NetworkState
    @StateObject private var widgetTimelineReloader = WidgetTimelineReloader()

    private var selectedMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    private var filteredMergeRequests: [UniversalMergeRequest] {
        guard let activeRepoUrl = activeRepoUrl else {
            return selectedMergeRequests
        }

        return selectedMergeRequests.filter { $0.repoUrl == activeRepoUrl }
    }

    private var accountByID: [Account.ID: Account] {
        Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) })
    }

    private var rowModels: [MergeRequestRowModel] {
        filteredMergeRequests.map { request in
            MergeRequestRowModel(request: request, account: accountByID[request.accountsId])
        }
    }

    private var launchpadItems: [LaunchpadItemModel] {
        repos.map(LaunchpadItemModel.init)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            MergeRequestHeaderView(selectedView: $selectedView)

            if selectedView == .networkDebug {
                NetworkStateView()
            } else {
                MainContentView(
                    launchpadItems: launchpadItems,
                    rowModels: rowModels,
                    hasAccounts: !accounts.isEmpty,
                    withScrollView: true,
                    allowScrollBounce: true,
                    maxHeight: menuBarMaxHeight,
                    activeRepoUrl: $activeRepoUrl
                )
                .frame(maxHeight: menuBarMaxHeight)
            }
        }

        .frame(maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
        .onChange(of: selectedView) { _, newValue in
            if newValue == .networkDebug {
                networkState.record = true
            } else {
                networkState.record = false
            }
        }
        .onChange(of: filteredMergeRequests.map(\.id)) { _, _ in
            let listPublishID = OSSignpostID(log: perfLog)
            os_signpost(.event, log: perfLog, name: "list_data_published", signpostID: listPublishID)
        }
        .task(id: "once") {
            let startupSignpostID = OSSignpostID(log: perfLog)
            os_signpost(.begin, log: perfLog, name: "initial_load", signpostID: startupSignpostID)
            await fetchReviewRequestedMRs()
            await fetchAuthoredMRs()
            await fetchRepos()
            await branchPushes()
            os_signpost(.end, log: perfLog, name: "initial_load", signpostID: startupSignpostID)
        }
        .onReceive(timer) { _ in
            timelineDate = .now
            Task {
                let refreshSignpostID = OSSignpostID(log: perfLog)
                os_signpost(.begin, log: perfLog, name: "periodic_refresh", signpostID: refreshSignpostID)
                await fetchReviewRequestedMRs()
                await fetchAuthoredMRs()
                await fetchRepos()
                await branchPushes()
                os_signpost(.end, log: perfLog, name: "periodic_refresh", signpostID: refreshSignpostID)
            }
        }
    }

    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            guard isValidInstance(account) else { continue }
            let info = NetworkInfo(label: "Fetch Review Requested Merge Requests", account: account, method: .get)
            switch account.provider {
            case .GitLab:
                let results: [GitLab.MergeRequest]? = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchReviewRequestedMergeRequests(with: account)
                }

                if let results {
                    do {
                        try await removeAndInsertUniversal(
                            .reviewRequestedMergeRequests,
                            account: account,
                            results: results
                        )
                    } catch {
                        reportPersistenceFailure("[\(account.provider.rawValue)] Failed to save review requested requests: \(error.localizedDescription)")
                    }
                }
            case .GitHub:
                let results: [GitHub.PullRequestsNode]? = await wrapRequest(info: info) {
                    try await NetworkManagerGitHub.shared.fetchReviewRequestedPullRequests(with: account)
                }

                if let results {
                    do {
                        try await removeAndInsertUniversal(
                            .reviewRequestedMergeRequests,
                            account: account,
                            results: results
                        )
                    } catch {
                        reportPersistenceFailure("[\(account.provider.rawValue)] Failed to save review requested requests: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
            guard isValidInstance(account) else { continue }
            let info = NetworkInfo(
                label: "Fetch Authored Merge Requests",
                account: account,
                method: .get
            )
            let requests: [UniversalMergeRequest]? = await wrapRequest(info: info) {
                switch account.provider {
                case .GitLab:
                    return try await NetworkManagerGitLab.shared.fetchAuthoredMergeRequests(with: account)
                case .GitHub:
                    return try await NetworkManagerGitHub.shared.fetchAuthoredPullRequests(with: account)
                }
            }

            guard let requests else { continue }

            do {
                try await removeAndInsertUniversal(.authoredMergeRequests, account: account, requests: requests)
            } catch {
                reportPersistenceFailure("[\(account.provider.rawValue)] Failed to save authored requests: \(error.localizedDescription)")
            }
        }
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, results: [GitLab.MergeRequest]) async throws {
        // Map results to universal request
        let requests = results.map { result in
            return UniversalMergeRequest(
                request: result,
                account: account,
                provider: .GitLab,
                type: type
            )
        }
        // Call universal remove and insert
        try await removeAndInsertUniversal(type, account: account, requests: requests)
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, results: [GitHub.PullRequestsNode]) async throws {
        let requests = results.map { result in
            return UniversalMergeRequest(
                request: result,
                account: account,
                provider: .GitHub,
                type: type
            )
        }
        // Call universal remove and insert
        try await removeAndInsertUniversal(type, account: account, requests: requests)
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, requests: [UniversalMergeRequest]) async throws {
        let incomingIds = requests.map(\.id)
        let existingForAccountType = mergeRequests.filter { existingMR in
            existingMR.accountsId == account.id &&
            existingMR.provider == account.provider &&
            existingMR.type == type
        }
        let mrsToRemove = existingForAccountType.filter { !incomingIds.contains($0.id) }
        let noChanges = hasNoMRChanges(existing: existingForAccountType, incoming: requests, removals: mrsToRemove)

        if noChanges {
            return
        }

        let persistSignpostID = OSSignpostID(log: perfLog)
        os_signpost(.begin, log: perfLog, name: "persist_mrs", signpostID: persistSignpostID)
        try await database.write { db in
            // Delete stale items for this account + provider + type
            for mrToRemove in mrsToRemove {
                try UniversalMergeRequest.delete(mrToRemove).execute(db)
            }

            // Upsert incoming items (updates existing + inserts new)
            for request in requests {
                try UniversalMergeRequest.upsert(UniversalMergeRequest.Draft(request)).execute(db)
            }
        }
        os_signpost(.end, log: perfLog, name: "persist_mrs", signpostID: persistSignpostID)

        // Request widget refresh when MRs are updated
        reloadMergeRequestWidgetsIfNeeded()

        // Update the repository's updatedAt field
        for request in requests {
            if let repoUrl = request.repoUrl {
                if var repo = repos.first(where: { $0.url == repoUrl }) {
                    if repo.updatedAt < request.updatedAt {
                        repo.updatedAt = request.updatedAt
                        let repoToUpdate = repo
                        try await database.write { db in
                            try LaunchpadRepo.upsert(LaunchpadRepo.Draft(repoToUpdate)).execute(db)
                        }
                    }
                }
            }
        }
    }

    private func hasNoMRChanges(existing: [UniversalMergeRequest], incoming: [UniversalMergeRequest], removals: [UniversalMergeRequest]) -> Bool {
        guard removals.isEmpty else {
            return false
        }

        guard existing.count == incoming.count else {
            return false
        }

        // Compare payloads instead of just updatedAt: pipeline/CI job updates
        // do not bump the merge request's updatedAt, but must still be persisted.
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        for request in incoming {
            guard let existingRequest = existingByID[request.id],
                  existingRequest.mergeRequest == request.mergeRequest,
                  existingRequest.pullRequest == request.pullRequest,
                  existingRequest.type == request.type,
                  existingRequest.provider == request.provider else {
                return false
            }
        }

        return true
    }

    // TDOO: fix this mess with split gitlab (below) and github (above) logic
    @MainActor
    private func fetchRepos() async {
        for account in accounts {
            guard isValidInstance(account) else { continue }
            if account.provider == .GitLab {
                let ids = Array(Set(mergeRequests.compactMap { request in
                    if request.provider == .GitLab {
                        return request.mergeRequest?.targetProject?.id.split(separator: "/").last
                    } else {
                        return nil
                    }
                }.compactMap({ Int($0) })))

                let info = NetworkInfo(label: "Fetch Projects \(ids)", account: account, method: .get)
                let results = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchProjects(with: account, ids: ids)
                }

                if let results {
                    for result in results {
                        if let url = result.webURL {
                            // Check if repo already exists in database
                            let existingRepo = repos.first { $0.url == url }

                            if let existingRepo {
                                logger.debug("updating repo \(existingRepo.name) (\(existingRepo.url.absoluteString))")
                                // Update existing repo if it hasn't been updated since launch
                                if existingRepo.hasUpdatedSinceLaunch == false {
                                    var updatedRepo = existingRepo
                                    if let name = result.name {
                                        updatedRepo.name = name
                                    }
                                    if let owner = result.group?.fullName ?? result.namespace?.fullName {
                                        updatedRepo.group = owner
                                    }
                                    updatedRepo.url = url
                                    if let image = await NetworkManagerGitLab.shared.getProjectImage(with: account, result) {
                                        updatedRepo.image = image
                                    }
                                    updatedRepo.provider = account.provider
                                    updatedRepo.hasUpdatedSinceLaunch = true
                                    
                                    let repoToUpdate = updatedRepo
                                    do {
                                        try await database.write { db in
                                            try repoToUpdate.update(db)
                                        }
                                    } catch {
                                        reportPersistenceFailure("[GitLab] Failed to update repo \(updatedRepo.name): \(error.localizedDescription)")
                                    }
                                }
                            } else {
                                // Insert new repo
                                let repo = LaunchpadRepo(
                                    id: result.id,
                                    name: result.name ?? "",
                                    image: await NetworkManagerGitLab.shared.getProjectImage(with: account, result),
                                    group: result.group?.fullName ?? result.namespace?.fullName ?? "",
                                    url: url,
                                    provider: account.provider,
                                    hasUpdatedSinceLaunch: true
                                )
                                
                                do {
                                    try await database.write { db in
                                        try LaunchpadRepo.upsert(LaunchpadRepo.Draft(repo)).execute(db)
                                    }
                                } catch {
                                    reportPersistenceFailure("[GitLab] Failed to insert repo \(repo.name): \(error.localizedDescription)")
                                }
                                
                                // Request widget refresh when repos are updated
                                reloadLaunchpadWidgetIfNeeded()
                            }
                        }
                    }
                }
            } else if account.provider == .GitHub {
                // Extract unique repositories from GitHub pull requests
                let githubRepos = mergeRequests
                    .filter { $0.provider == .GitHub && $0.accountsId == account.id }
                    .compactMap { request -> (id: String, name: String, owner: String, url: URL, image: String, updatedAt: Date)? in
                        guard let repo = request.pullRequest?.repository,
                              let repoUrl = request.repoUrl,
                              let repoName = request.repoName,
                              let repoOwner = request.repoOwner else {
                            return nil
                        }
                        
                        return (
                            id: repo.id ?? "github-\(UUID().uuidString)",
                            name: repoName,
                            owner: repoOwner,
                            url: repoUrl,
                            image: request.repoImage?.absoluteString ?? "",
                            updatedAt: request.updatedAt
                        )
                    }
                
                // Get unique repositories
                let uniqueRepos = Dictionary(grouping: githubRepos, by: { $0.url })
                    .compactMap { $0.value.first }
                
                for githubRepo in uniqueRepos {
                    // Check if repo already exists in database
                    let existingRepo = repos.first { $0.url == githubRepo.url }
                    
                    if let existingRepo {
                        logger.debug("updating GitHub repo \(existingRepo.name) (\(existingRepo.url.absoluteString))")
                        // Update existing repo if it hasn't been updated since launch
                        if existingRepo.hasUpdatedSinceLaunch == false {
                            var updatedRepo = existingRepo
                            updatedRepo.name = githubRepo.name
                            updatedRepo.group = githubRepo.owner
                            updatedRepo.url = githubRepo.url
                            updatedRepo.imageURL = githubRepo.image
                            updatedRepo.provider = account.provider
                            updatedRepo.hasUpdatedSinceLaunch = true
                            updatedRepo.updatedAt = existingRepo.updatedAt

                            let repoToUpdate = updatedRepo
                            do {
                                try await database.write { db in
                                    try repoToUpdate.update(db)
                                }
                            } catch {
                                reportPersistenceFailure("[GitHub] Failed to update repo \(updatedRepo.name): \(error.localizedDescription)")
                            }
                            
                            // Request widget refresh when repos are updated
                            reloadLaunchpadWidgetIfNeeded()
                        }
                    } else {
                        // Insert new repo
                        let repo = LaunchpadRepo(
                            id: githubRepo.id,
                            name: githubRepo.name,
                            image: nil,
                            imageURL: githubRepo.image,
                            group: githubRepo.owner,
                            url: githubRepo.url,
                            provider: account.provider,
                            hasUpdatedSinceLaunch: true,
                            updatedAt: githubRepo.updatedAt
                        )
                        
                        do {
                            try await database.write { db in
                                try LaunchpadRepo.upsert(LaunchpadRepo.Draft(repo)).execute(db)
                            }
                        } catch {
                            reportPersistenceFailure("[GitHub] Failed to insert repo \(repo.name): \(error.localizedDescription)")
                        }
                        
                        // Request widget refresh when repos are updated
                        reloadLaunchpadWidgetIfNeeded()
                    }
                }
            }
        }
    }

    @MainActor
    private func branchPushes() async {
        for account in accounts {
            if account.provider == .GitLab {
                guard isValidInstance(account) else { continue }
                let info = NetworkInfo(label: "Fetch Branch Push", account: account, method: .get)
                let notice = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchLatestBranchPush(with: account, repos: repos)
                }

                if let notice {
                    if notice.type == .branch, let branch = notice.branchRef {

                        let matchedMR = selectedMergeRequests.first { request in
                            return request.sourceBranch == branch
                        }

                        let alreadyHasMR = matchedMR != nil

                        if alreadyHasMR || !notice.createdAt.isWithinLastHours(1) {
                            logger.debug("Fetch Branch Push: skipping notice for '\(branch)' (alreadyHasMR: \(alreadyHasMR), createdAt: \(notice.createdAt))")
                            continue
                        }
                    }
                    noticeState.addNotice(notice: notice)
                } else {
                    logger.debug("Fetch Branch Push: no notice returned for \(account.instance)")
                }
            }
        }
    }

    @MainActor
    private func wrapRequest<T>(info: NetworkInfo, do request: () async throws -> T?) async -> T? {
        logger.info("[\(info.method.rawValue)] [\(info.account.instance.replacingOccurrences(of: "https://", with: ""))] \(info.label)")
        let event = NetworkEvent(info: info, status: nil, response: nil)
        networkState.add(event)
        do {
            let result = try await request()
            event.status = 200
            event.response = result.debugDescription
            networkState.update(event)
            return result
        } catch APIError.unacceptableStatusCode(let statusCode) {
            logger.warning("\(info.label) failed with status code \(statusCode)")
            event.status = statusCode
            event.response = "Unacceptable Status Code: \(statusCode)"
            networkState.update(event)
        } catch let error {
            logger.error("\(info.label) failed: \(String(describing: error))")
            event.status = 0
            event.response = error.localizedDescription
            networkState.update(event)
        }

        return nil

    }

    private func reloadMergeRequestWidgetsIfNeeded() {
        widgetTimelineReloader.scheduleReload(kind: "AuthoredMergeRequestWidget")
        widgetTimelineReloader.scheduleReload(kind: "ReviewRequestedMergeRequestWidget")
    }

    private func reloadLaunchpadWidgetIfNeeded() {
        widgetTimelineReloader.scheduleReload(kind: "LaunchpadWidget")
    }

    private func reportPersistenceFailure(_ message: String) {
        noticeState.addNotice(
            notice: NoticeMessage(
                label: message,
                type: .error
            )
        )
    }

    private func isValidInstance(_ account: Account) -> Bool {
        guard var components = URLComponents(string: account.instance) else {
            reportPersistenceFailure("Invalid \(account.provider.rawValue) instance URL: \(account.instance)")
            return false
        }

        if components.scheme == nil {
            components.scheme = "https"
        }

        guard components.host != nil else {
            reportPersistenceFailure("Invalid \(account.provider.rawValue) instance URL: \(account.instance)")
            return false
        }

        return true
    }

    private var menuBarMaxHeight: CGFloat? {
#if os(macOS)
        return NSScreen.main.map { $0.visibleFrame.height * 0.9 }
        // return 700
#else
        return nil
#endif
    }
}

@MainActor
private final class WidgetTimelineReloader: ObservableObject {
    private var lastReloadAt: [String: Date] = [:]
    private let cooldown: TimeInterval = 5

    func scheduleReload(kind: String) {
        let now = Date.now
        if let previous = lastReloadAt[kind], now.timeIntervalSince(previous) < cooldown {
            return
        }
        lastReloadAt[kind] = now
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}

#Preview {
    HStack(alignment: .top) {
        UserInterface()
            .environmentObject(NoticeState())
            .environmentObject(NetworkState())
//            .frame(maxHeight: .infinity, alignment: .top)
        //            .modelContainer(.previews)
    }
}

// NotificationManager.shared.sendNotification(
//    title: title,
//    subtitle: "\(reference) is approved by \(approvers.formatted())",
//    userInfo: userInfo
// )

private struct MergeRequestHeaderView: View {
    @Binding var selectedView: QueryType
    @EnvironmentObject private var settings: SettingsState

    var body: some View {
        Picker(selection: $selectedView, content: {
            Text("\(settings.language.rawValue)s").tag(QueryType.authoredMergeRequests)
            Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
#if DEBUG
            Text("Debug Network").tag(QueryType.networkDebug)
#endif
        }, label: {
            EmptyView()
        })
        .pickerStyle(.segmented)
        .padding(.horizontal, 6)
        .padding(.top, 6)
        .padding(.bottom, 0)
    }
}
