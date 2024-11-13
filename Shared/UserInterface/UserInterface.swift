//
//  UserInterface.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData
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
    @Environment(\.modelContext) private var modelContext

    @Query private var accounts: [Account]
    @Query(
        sort: \LaunchpadRepo.createdAt,
        order: .reverse
    ) private var repos: [LaunchpadRepo]
    @Query(
        sort: \UniversalMergeRequest.createdAt,
        order: .reverse
    ) private var mergeRequests: [UniversalMergeRequest]

    @State private var selectedView: QueryType = .authoredMergeRequests

    @State private var timelineDate: Date = .now
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @EnvironmentObject private var noticeState: NoticeState
    @EnvironmentObject private var networkState: NetworkState

    private var filteredMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
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
                    selectedView: $selectedView
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
                let results = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchReviewRequestedMergeRequests(with: account)
                }

                if let results {
                    removeAndInsertUniversal(
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
            if account.provider == .GitLab {
                let info = NetworkInfo(
                    label: "Fetch Authored Merge Requests",
                    account: account,
                    method: .get
                )
                let results = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchAuthoredMergeRequests(with: account)
                }

                if let results {
                    removeAndInsertUniversal(
                        .authoredMergeRequests,
                        account: account,
                        results: results
                    )
                }
            } else {
                let info = NetworkInfo(
                    label: "Fetch Authored Pull Requests",
                    account: account,
                    method: .get
                )
                let results = await wrapRequest(info: info) {
                    try await NetworkManagerGitHub.shared.fetchAuthoredPullRequests(with: account)
                }

                if let results {
                    removeAndInsertUniversal(
                        .authoredMergeRequests,
                        account: account,
                        results: results
                    )
                }
            }
        }
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, results: [GitLab.MergeRequest]) {
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
        removeAndInsertUniversal(type, account: account, requests: requests)
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, results: [GitHub.PullRequestsNode]) {
        // Map results to universal request
        let requests = results.map { result in
            return UniversalMergeRequest(
                request: result,
                account: account,
                provider: .GitHub,
                type: type
            )
        }
        // Call universal remove and insert
        removeAndInsertUniversal(type, account: account, requests: requests)
    }

    private func removeAndInsertUniversal(_ type: QueryType, account: Account, requests: [UniversalMergeRequest]) {
        // Get array of ids of current of type
        let existing = mergeRequests.filter({ $0.type == type }).map({ $0.requestID })
        // Get arary of new of current of type
        let updated = requests.map { $0.requestID }
        // Compute difference
        let difference = existing.difference(from: updated)
        // Delete existing
        for pullRequest in account.requests {
            if difference.contains(pullRequest.requestID) {
                print("removing \(pullRequest.requestID)")
                modelContext.delete(pullRequest)
                try? modelContext.save()
            }
        }

        for request in requests {
            // update values
            if let existingMR = mergeRequests.first(where: { request.requestID == $0.requestID }) {
                existingMR.mergeRequest = request.mergeRequest
                existingMR.pullRequest = request.pullRequest
            } else {
                // if not insert
                modelContext.insert(request)
            }

            // If no matching launchpad repo, insert a new one
            let launchPadItem = repos.first { repo in
                repo.url == request.repoUrl
            }

            if let launchPadItem {
                if launchPadItem.hasUpdatedSinceLaunch == false {
                    if let name = request.repoName {
                        launchPadItem.name = name
                    }
                    if let owner = request.repoOwner {
                        launchPadItem.group = owner
                    }
                    if  let url = request.repoUrl {
                        launchPadItem.url = url
                    }
                    if let imageURL = request.repoImage {
                        launchPadItem.imageURL = imageURL
                    }
                    launchPadItem.provider = request.provider
                    launchPadItem.hasUpdatedSinceLaunch = true
                }
            } else if let name = request.repoName,
                      let owner = request.repoOwner,
                      let url = request.repoUrl {

                let repo = LaunchpadRepo(
                    id: request.repoId ?? UUID().uuidString,
                    name: name,
                    imageURL: request.repoImage,
                    group: owner,
                    url: url,
                    provider: request.provider
                )

                modelContext.insert(repo)
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
                            // If no matching launchpad repo, insert a new one
                            let launchPadItem = repos.first { repo in
                                repo.url == url
                            }

                            if let launchPadItem {
                                if launchPadItem.hasUpdatedSinceLaunch == false {
                                    if let name = result.name {
                                        launchPadItem.name = name
                                    }
                                    if let owner = result.group?.fullName ?? result.namespace?.fullName {
                                        launchPadItem.group = owner
                                    }
                                    launchPadItem.url = url
                                    if let image = await NetworkManagerGitLab.shared.getProjectImage(with: account, result) {
                                        launchPadItem.image = image
                                    }
                                    launchPadItem.provider = account.provider
                                    launchPadItem.hasUpdatedSinceLaunch = true
                                }
                            } else {
                                let repo = LaunchpadRepo(
                                    id: result.id,
                                    name: result.name ?? "",
                                    image: await NetworkManagerGitLab.shared.getProjectImage(with: account, result),
                                    group: result.group?.fullName ?? result.namespace?.fullName ?? "",
                                    url: url,
                                    hasUpdatedSinceLaunch: true
                                )
                                modelContext.insert(repo)
                            }
                        }
                    }
                    try? modelContext.save()
                }
            }
        }
    }

    @MainActor
    private func branchPushes() async {
        for account in accounts {
            if account.provider == .GitLab {
                let info = NetworkInfo(label: "Branch Push", account: account, method: .get)
                let notice = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchLatestBranchPush(with: account, repos: repos)
                }

                if let notice {
                    if notice.type == .branch, let branch = notice.branchRef {

                        let matchedMR = filteredMergeRequests.first { request in
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
            .modelContainer(.previews)
            .environmentObject(NoticeState())
            .environmentObject(NetworkState())
            .frame(maxHeight: .infinity, alignment: .top)
            .scenePadding()
    }
    .scenePadding()
}

// NotificationManager.shared.sendNotification(
//    title: title,
//    subtitle: "\(reference) is approved by \(approvers.formatted())",
//    userInfo: userInfo
// )
