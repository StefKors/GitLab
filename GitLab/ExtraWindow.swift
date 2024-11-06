//
//  ExtraWindow.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SwiftData
import BackgroundFetcher
import OSLog

struct ExtraWindow: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()
    @Query(sort: \UniversalMergeRequest.createdAt, order: .reverse) private var mergeRequests: [UniversalMergeRequest]
    @Query private var accounts: [Account]
    @Query(sort: \LaunchpadRepo.createdAt, order: .reverse) private var repos: [LaunchpadRepo]

    @State private var selectedView: QueryType = .authoredMergeRequests

    private var filteredMergeRequests: [UniversalMergeRequest] {
        mergeRequests.filter { $0.type == selectedView }
    }

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.appearsActive) private var appearsActive
    @State private var hasLoaded: Bool = false

    let log = Logger(subsystem: "ExtraWindow", category: "ExtraBG")


//    let backgroundUpdateTimer: NSBackgroundActivityScheduler = {
//        let scheduler: NSBackgroundActivityScheduler = .init(identifier: "com.stefkors.GitLab.backgroundAutoUpdate")
//        scheduler.repeats = true
//        scheduler.interval = 3
//        scheduler.tolerance = 0
//        scheduler.qualityOfService = .userInteractive
//
//        return scheduler
//    }()

    var body: some View {
        VStack {
            Divider()
            MainContentView(
                repos: repos,
                filteredMergeRequests: filteredMergeRequests,
                accounts: accounts,
                withScrollView: true,
                selectedView: $selectedView
            )
        }
        .overlay(content: {
            Rectangle()
                .fill(.windowBackground)
                .opacity(appearsActive && hasLoaded ? 0 : 0.4)
                .allowsHitTesting(false)
                .task {
                    hasLoaded = true
                }
        })
        .environmentObject(self.noticeState)
        .environmentObject(self.networkState)
        .onOpenURL { url in
            openURL(url)
        }
        .toolbar {
            ToolbarItem {
                Picker(selection: $selectedView, content: {
                    Text("Merge Requests").tag(QueryType.authoredMergeRequests)
                    Text("Review requested").tag(QueryType.reviewRequestedMergeRequests)
                }, label: {
                    EmptyView()
                })
                .pickerStyle(.segmented)
            }
        }
//        .onAppear {
//            callXPC()



//            if let session = try? XPCSession(xpcService: serviceName) {
//                let request = CalculationRequest(firstNumber: 23, secondNumber: 19)
//                try? session.send(request)
//            }
//        }
//        .onAppear {
//            log.warning("Jenga 1 start backgroundUpdateTimer")
//            // Start the background update scheduler when the app starts
//            backgroundUpdateTimer.schedule
//            { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
//                log.warning("Jenga 5 (background task success)")
//                completion(NSBackgroundActivityScheduler.Result.finished)
//
//            }
//        }
    }

//    @MainActor
//    func callXPC() {
//        let serviceName = "com.stefkors.BackgroundFetcher"
//        let connection = NSXPCConnection(serviceName: serviceName)
//        connection.remoteObjectInterface = NSXPCInterface(with: BackgroundFetcherProtocol.self)
//        connection.resume()
//
//        let service = connection.remoteObjectProxyWithErrorHandler { error in
//            print("Received error:", error)
//        } as? BackgroundFetcherProtocol
//
//        log.warning("Jenga before calc 32")
//
//        service?.performCalculation(firstNumber: 12, secondNumber: 20)
//    }
}

// A codable type that contains two numbers to add together.
struct CalculationRequest: Codable {
    let firstNumber: Int
    let secondNumber: Int
}

struct CalcuationResponse: Codable {
    let result: Int
}
