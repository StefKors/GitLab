//
//  BackgroundFetcher.swift
//  BackgroundFetcher
//
//  Created by Stef Kors on 03/11/2024.
//

import Foundation
import OSLog
import SwiftData
import Get

/// ```swift
///  // It is important that this actor works as a mutex,
///  // so you must have one instance of the Actor for one container
//   // for it to work correctly.
///  let actor = BackgroundSerialPersistenceActor(container: modelContainer)
///
///  Task {
///      let data: [MyModel] = try? await actor.fetchData()
///  }
///  ```
//@available(iOS 17, *)
//public actor BackgroundSerialPersistenceActor: ModelActor {
//
//    public let modelContainer: ModelContainer
//    public let modelExecutor: any ModelExecutor
//    private var context: ModelContext { modelExecutor.modelContext }
//
//    public init(container: ModelContainer) {
//        self.modelContainer = container
//        let context = ModelContext(modelContainer)
//        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
//    }
//
//    public func fetchData<T: PersistentModel>(
//        predicate: Predicate<T>? = nil,
//        sortBy: [SortDescriptor<T>] = []
//    ) throws -> [T] {
//        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
//        let list: [T] = try context.fetch(fetchDescriptor)
//        return list
//    }
//
//    public func fetchCount<T: PersistentModel>(
//        predicate: Predicate<T>? = nil,
//        sortBy: [SortDescriptor<T>] = []
//    ) throws -> Int {
//        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
//        let count = try context.fetchCount(fetchDescriptor)
//        return count
//    }
//
//    public func insert<T: PersistentModel>(_ data: T) {
//        let context = data.modelContext ?? context
//        context.insert(data)
//    }
//
//    public func save() throws {
//        try context.save()
//    }
//
//    public func remove<T: PersistentModel>(predicate: Predicate<T>? = nil) throws {
//        try context.delete(model: T.self, where: predicate)
//    }
//
//    public func delete<T: PersistentModel>(_ model: T) throws {
//        try context.delete(model)
//    }
//
//    public func saveAndInsertIfNeeded<T: PersistentModel>(
//        data: T,
//        predicate: Predicate<T>
//    ) throws {
//        let descriptor = FetchDescriptor<T>(predicate: predicate)
//        let context = data.modelContext ?? context
//        let savedCount = try context.fetchCount(descriptor)
//
//        if savedCount == 0 {
//            context.insert(data)
//        }
//        try context.save()
//    }
//}
//
@ModelActor
public actor ModelActorDatabase {
    @MainActor
    public init(modelContainer: ModelContainer, mainActor _: Bool) {
        let modelContext = modelContainer.mainContext
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
    }

    public func delete(_ model: some PersistentModel) async {
        self.modelContext.delete(model)
    }

    public func insert(_ model: some PersistentModel) async {
        self.modelContext.insert(model)
    }

    public func delete<T: PersistentModel>(
        where predicate: Predicate<T>?
    ) async throws {
        try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func save() async throws {
        try self.modelContext.save()
    }

    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
        return try self.modelContext.fetch(descriptor)
    }

    public func fetchData<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try self.modelContext.fetch(fetchDescriptor)
        return list
    }
}

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class BackgroundFetcher: NSObject, BackgroundFetcherProtocol {
    let log = Logger()

    let activity = NSBackgroundActivityScheduler(identifier: "com.stefkors.GitLab.updatecheck")

    var count: Int = 0
    var date = Date.now

    let actor = ModelActorDatabase(modelContainer: .shared)

    func startFetching() {
        log.info("startFetching is called")
        activity.invalidate()
        activity.repeats = true
        activity.interval = 20 // seconds
        activity.tolerance = 1
        activity.qualityOfService = .userInteractive

//        Task {
//            await self.fetchReviewRequestedMRs()
//            await self.fetchAuthoredMRs()
//            await self.fetchRepos()
//            await self.branchPushes()
//        }

        activity.schedule { [weak self] completion in
            print("run schedule")

            Task {
                do {
                    try await self?.fetchReviewRequestedMRs()
                    try await self?.fetchAuthoredMRs()
                    try await self?.fetchRepos()
                    try await self?.branchPushes()
                } catch {
                    print("Error in background fetcher: \(error.localizedDescription)")
                }
            }

            let newDate = Date.now
            let interval = newDate.timeIntervalSince(self?.date ?? Date.now)
            self?.log.info("startFetching: \(self?.count.description ?? "") sinceLast: \(interval) seconds should defer? \(self?.activity.shouldDefer ?? false)")
            self?.count += 1
            self?.date = Date.now
            completion(.finished)
        }
    }

    @MainActor
    private func fetchReviewRequestedMRs() async throws {
        let accounts: [Account] = try await actor.fetchData()
//        let context = ModelContext(.shared)
//        let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []

        for account in accounts {
            if account.provider == .GitLab {
                let info = NetworkInfo(label: "Fetch Review Requested Merge Requests", account: account, method: .get)
                let results = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchReviewRequestedMergeRequests(with: account)
                }

                if let results {
                    try await removeAndInsertUniversal(
                        .reviewRequestedMergeRequests,
                        account: account,
                        results: results
                    )
                }
            }
        }
    }

    @MainActor
    private func fetchAuthoredMRs() async throws {
//        let context = ModelContainer.shared.mainContext
//        let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
        let accounts: [Account] = try await actor.fetchData()

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
                    try await removeAndInsertUniversal(
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
                    try await removeAndInsertUniversal(
                        .authoredMergeRequests,
                        account: account,
                        results: results
                    )
                }
            }
        }
    }

    @MainActor
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

    @MainActor
    private func removeAndInsertUniversal(_ type: QueryType, account: Account, results: [GitHub.PullRequestsNode]) async throws {
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
        try await removeAndInsertUniversal(type, account: account, requests: requests)
    }

    @MainActor
    private func removeAndInsertUniversal(_ type: QueryType, account: Account, requests: [UniversalMergeRequest]) async throws {
        let mergeRequests: [UniversalMergeRequest] = try await actor.fetchData()
        let repos: [LaunchpadRepo] = try await actor.fetchData()
//        let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
//        let mergeRequests = (try? context.fetch(FetchDescriptor<UniversalMergeRequest>())) ?? []
//        let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []

        // Get array of ids of current of type
        let existing = mergeRequests.filter({ $0.type == type }).map({ $0.requestID })
        // Get array of new of current of type
        let updated = requests.map { $0.requestID }
        // Compute difference
        let difference = existing.difference(from: updated)
        // Delete existing
        for pullRequest in account.requests {
            if difference.contains(pullRequest.requestID) {
                print("removing \(pullRequest.requestID)")
                await actor.delete(pullRequest)
                try await actor.save()
            }
        }

        for request in requests {
            // update values
            if let existingMR = mergeRequests.first(where: { request.requestID == $0.requestID }) {
                existingMR.mergeRequest = request.mergeRequest
                existingMR.pullRequest = request.pullRequest
            } else {
                // if not insert
                await actor.insert(request)
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

                await actor.insert(repo)
            }
        }
    }

    // TDOO: fix this mess with split gitlab (below) and github (above) logic
    @MainActor
    private func fetchRepos() async throws {
        let accounts: [Account] = try await actor.fetchData()
        let mergeRequests: [UniversalMergeRequest] = try await actor.fetchData()
        let repos: [LaunchpadRepo] = try await actor.fetchData()
//        let mergeRequests = (try? context.fetch(FetchDescriptor<UniversalMergeRequest>())) ?? []
//        let repos = (try? context.fetch(FetchDescriptor<LaunchpadRepo>())) ?? []

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
                                await actor.insert(repo)
                            }
                        }
                    }
                    try await actor.save()
                }
            }
        }
    }

    @MainActor
    private func branchPushes() async throws {
        let accounts: [Account] = try await actor.fetchData()
        let mergeRequests: [UniversalMergeRequest] = try await actor.fetchData()
        let repos: [LaunchpadRepo] = try await actor.fetchData()


        for account in accounts {
            if account.provider == .GitLab {
                let info = NetworkInfo(label: "Branch Push", account: account, method: .get)
                let notice = await wrapRequest(info: info) {
                    try await NetworkManagerGitLab.shared.fetchLatestBranchPush(with: account, repos: repos)
                }

                if let notice {
                    if notice.type == .branch, let branch = notice.branchRef {

                        let matchedMR = mergeRequests.first { request in
                            return request.sourceBranch == branch
                        }

                        let alreadyHasMR = matchedMR != nil

                        if alreadyHasMR || !notice.createdAt.isWithinLastHours(1) {
                            return
                        }
                    }
                    await actor.insert(notice)
                }
            }
        }
    }

    @MainActor
    private func wrapRequest<T>(info: NetworkInfo, do request: () async throws -> T?) async -> T? {
//        let context = ModelContainer.shared.mainContext
        let event = NetworkEvent(info: info, status: nil, response: nil)
        await actor.insert(event)
        do {
            let result = try await request()
            event.status = 200
            event.response = result.debugDescription
//            networkState.update(event)
            return result
        } catch APIError.unacceptableStatusCode(let statusCode) {
            event.status = statusCode
            event.response = "Unacceptable Status Code: \(statusCode)"
//            networkState.update(event)
        } catch let error {
            event.status = 0
            event.response = error.localizedDescription
//            networkState.update(event)
        }

        return nil
    }
}
