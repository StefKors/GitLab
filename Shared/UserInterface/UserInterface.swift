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
    
    @Query(sort: \MergeRequest.createdAt) private var mergeRequests: [MergeRequest]
//    @Query private var mergeRequests: [MergeRequest]
    @Query private var accounts: [Account]
    @Query private var repos: [LaunchpadRepo]
    
    @State private var selectedView: QueryType = .authoredMergeRequests
    
    @State private var timelineDate: Date = .now
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject private var noticeState: NoticeState
    @EnvironmentObject private var networkState: NetworkState
    
    private var filteredMergeRequests: [MergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker(selection: $selectedView, content: {
                Text("Your Merge Requests").tag(QueryType.authoredMergeRequests)
                Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
#if DEBUG
                Text("Debug").tag(QueryType.networkDebug)
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
            }
        }
        
        .frame(maxHeight: .infinity, alignment: .top)
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
        .onReceive(timer) { time in
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
            let info = NetworkInfo(label: "Fetch Review Requested Merge Requests", account: account, method: .get)
            let results = await wrapRequest(info: info) {
                try await NetworkManager.shared.fetchReviewRequestedMergeRequests(with: account)?.map { mr in
                    mr.account = account
                    mr.type = .reviewRequestedMergeRequests
                    return mr
                }
            }
            
            if let results {
                removeAndInsertMRs(.reviewRequestedMergeRequests, account: account, results: results)
            }
        }
    }
    
    @MainActor
    private func fetchAuthoredMRs() async {
        for account in accounts {
            let info = NetworkInfo(label: "Fetch Authored Merge Requests", account: account, method: .get)
            let results = await wrapRequest(info: info) {
                try await NetworkManager.shared.fetchAuthoredMergeRequests(with: account)?.map { mr in
                    mr.account = account
                    mr.type = .authoredMergeRequests
                    return mr
                }
            }
            
            if let results {
                removeAndInsertMRs(.authoredMergeRequests, account: account, results: results)
            }
        }
    }
    
    private func removeAndInsertMRs(_ type: QueryType, account: Account, results: [MergeRequest]) {
        print("inserting \(results.count) merge requests \(type.rawValue)")
        let existing = account.mergeRequests.filter({ $0.type == type }).map({ $0.mergerequestID })
        let updated = results.map { $0.mergerequestID }
        let difference = existing.difference(from: updated)
        
        for mergeRequest in account.mergeRequests {
            if difference.contains(mergeRequest.mergerequestID) {
                modelContext.delete(mergeRequest)
            }
        }
        
        for result in results {
            modelContext.insert(result)
        }
        try? modelContext.save()
    }
    
    @MainActor
    private func fetchRepos() async {
        for account in accounts {
            let ids = Array(Set(mergeRequests.compactMap { mr in
                return mr.targetProject?.id.split(separator: "/").last
            }.compactMap({ Int($0) })))
            
            let info = NetworkInfo(label: "Fetch Projects \(ids)", account: account, method: .get)
            let results = await wrapRequest(info: info) {
                try await NetworkManager.shared.fetchProjects(with: account, ids: ids)
            }
            
            if let results {
                for result in results {
                    modelContext.insert(result)
                }
                try? modelContext.save()
            }
        }
    }
    
    @MainActor
    private func branchPushes() async {
        for account in accounts {
            let info = NetworkInfo(label: "Branch Push", account: account, method: .get)
            let notice = await wrapRequest(info: info) {
                try await NetworkManager.shared.fetchLatestBranchPush(with: account, repos: repos)
            }
            
            if let notice {
                noticeState.addNotice(notice: notice)
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


public protocol OptionalType: ExpressibleByNilLiteral {
    associatedtype WrappedType
    var asOptional: WrappedType? { get }
}

extension Optional: OptionalType {
    public var asOptional: Wrapped? {
        return self
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



//NotificationManager.shared.sendNotification(
//    title: title,
//    subtitle: "\(reference) is approved by \(approvers.formatted())",
//    userInfo: userInfo
//)
