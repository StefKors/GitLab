//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SharingGRDB
import Get

/// TODO: Show different accounts
/// TODO: Show different git providers (GL / GH)
/// TODO: Filter by type
/// TODO: show assigned issues
/// TODO: widget?
/// TODO: timeline view updates
/// TODO: Reinstate clear notifications setting
/// TODO: Split networking
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

    @EnvironmentObject private var noticeState: NoticeState
    @EnvironmentObject private var networkState: NetworkState

    private var selectedMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    private var filteredMergeRequests: [UniversalMergeRequest] {
        guard let activeRepoUrl = activeRepoUrl else {
            return selectedMergeRequests
        }

        return selectedMergeRequests.filter { $0.repoUrl == activeRepoUrl }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker(selection: $selectedView, content: {
                Text("Your Pull Requests").tag(QueryType.authoredMergeRequests)
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

            if selectedView == .networkDebug {
                NetworkStateView()
            } else {
                MainContentView(
                    repos: repos,
                    filteredMergeRequests: filteredMergeRequests,
                    accounts: accounts,
                    selectedView: $selectedView,
                    activeRepoUrl: $activeRepoUrl
                )
                .task(id: filteredMergeRequests) {
                    print("filteredMergeRequests updated")
                }
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
        .task(id: "once") {
            Task {
                await fetchReviewRequestedMRs()
                await fetchAuthoredMRs()
                await fetchRepos()
                await branchPushes()
            }
        }
        .onReceive(timer) { _ in
            timelineDate = .now
            Task {
                await fetchReviewRequestedMRs()
                await fetchAuthoredMRs()
                await fetchRepos()
                await branchPushes()
            }
        }
    }

    /// TODO: Cleanup and move both into the same function
    @MainActor
    private func fetchReviewRequestedMRs() async {
        for account in accounts {
            if account.provider == .GitLab {
                let info = NetworkInfo(label: "Fetch Review Requested Merge Requests", account: account, method: .get)
                let results: [GitLab.MergeRequest]? = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchReviewRequestedMergeRequests(with: account)
                }

                if let results {
                    try? await removeAndInsertUniversal(
                        .reviewRequestedMergeRequests,
                        account: account,
                        results: results
                    )
                }
            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
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

            guard let requests else { return }

            do {
                try await removeAndInsertUniversal(.authoredMergeRequests, account: account, requests: requests)
            } catch {
                print("[\(account.provider)] Failed to insert: \(error.localizedDescription)")
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
        if requests.isEmpty {
            return
        }
        // Map results to universal request
        let incomingIds = requests.map(\.id)

        // Remove all MRs from this account that aren't included anymore
        let mrsToRemove = mergeRequests.filter { existingMR in
            let isAccount = existingMR.accountsId == account.id
            return isAccount && !incomingIds.contains(existingMR.id)
        }

        for mrToRemove in mrsToRemove {
            try await database.write { db in
                try UniversalMergeRequest.delete(mrToRemove).execute(db)
            }
        }

        for request in requests {
            try await database.write { db in
                try UniversalMergeRequest.upsert(UniversalMergeRequest.Draft(request)).execute(db)
            }

            // Update the repository's updatedAt field
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

    // TDOO: fix this mess with split gitlab (below) and github (above) logic
    @MainActor
    private func fetchRepos() async {
        for account in accounts {
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
                                print("updating \(existingRepo)")
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
                                    try? await database.write { db in
                                        try repoToUpdate.update(db)
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
                                
                                try? await database.write { db in
                                    try LaunchpadRepo.upsert(LaunchpadRepo.Draft(repo)).execute(db)
                                }
                            }
                        }
                    }
                }
            } else if account.provider == .GitHub {
                // Extract unique repositories from GitHub pull requests
                let githubRepos = mergeRequests
                    .filter { $0.provider == .GitHub && $0.accountsId == account.id }
                    .compactMap { request -> (id: String, name: String, owner: String, url: URL, image: URL?, updatedAt: Date)? in
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
                            image: request.repoImage,
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
                        print("updating GitHub repo \(existingRepo)")
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
                            try? await database.write { db in
                                try repoToUpdate.update(db)
                            }
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
                        
                        try? await database.write { db in
                            try LaunchpadRepo.upsert(LaunchpadRepo.Draft(repo)).execute(db)
                        }
                    }
                }
            }
        }
    }

    @MainActor
    private func branchPushes() async {
        for account in accounts {
            if account.provider == .GitLab {
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
                            return
                        }
                    }
                    noticeState.addNotice(notice: notice)
                }
            }
        }
    }

    @MainActor
    private func wrapRequest<T>(info: NetworkInfo, do request: () async throws -> T?) async -> T? {
        print("[\(info.method.rawValue)] [\(info.account.instance.replacingOccurrences(of: "https://", with: ""))] \(info.label)")
        let event = NetworkEvent(info: info, status: nil, response: nil)
        networkState.add(event)
        do {
            let result = try await request()
            event.status = 200
            event.response = result.debugDescription
            networkState.update(event)
            return result
        } catch APIError.unacceptableStatusCode(let statusCode) {
            event.status = statusCode
            event.response = "Unacceptable Status Code: \(statusCode)"
            networkState.update(event)
        } catch let error {
            print("catching error")
            event.status = 0
            event.response = error.localizedDescription
            networkState.update(event)
        }

        return nil

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
