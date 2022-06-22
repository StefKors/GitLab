//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Combine
import Defaults

enum RequestError: Error {
    case sessionError(error: Error)
}

class NetworkManager: ObservableObject {
    // https://gitlab.com/api/v4/projects/22103425/merge_requests?state=opened
    var openedMergeRequestsUrl = URL(string: "https://www.gitlab.com/api/v4/projects/22103425/merge_requests?state=opened")!
    var lastUpdate: Date = NSDate.now
    @Published var mergeRequests: [MergeRequestElement] = [] {
        didSet {
            print(mergeRequests)
            self.isUpdatingMRs = false
        }
    }
    @Published var isUpdatingMRs: Bool = false
    private var scope: Set<AnyCancellable> = []

    func getMRs() {
        isUpdatingMRs = true

        // network call
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Authorization": "Bearer \(Defaults[.apiToken])"]

        let session = URLSession(configuration: sessionConfiguration)
        session.dataTaskPublisher(for: openedMergeRequestsUrl)
            .map({ item in
                return item.data
            })
            .decode(type: [MergeRequestElement].self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<[MergeRequestElement], Never> in
                if error is URLError {
                    return Just([])
                        .eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
            }
            .retry(3)
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.mergeRequests, on: self)
            .store(in: &scope)
    }

    func getMRApprovals(id: Int) {
        isUpdatingMRs = true
        guard let approvalsUrl = URL(string: "https://www.gitlab.com/api/v4/projects/\(id)/merge_requests?state=opened"),
              let targetMR = mergeRequests.first(where: { $0.id == id }) else {
            isUpdatingMRs = false
            return
        }



        // network call
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Authorization": "Bearer \(Defaults[.apiToken])"]

        let session = URLSession(configuration: sessionConfiguration)
        // let result = session.dataTaskPublisher(for: approvalsUrl)
        //     .map({ item in
        //         return item.data
        //     })
        //     .decode(type: Approval.self, decoder: JSONDecoder())
        //     .catch { error -> AnyPublisher<Approval, Never> in
        //         if error is URLError {
        //             return Just(nil)
        //                 .eraseToAnyPublisher()
        //         } else {
        //             return Empty(completeImmediately: true)
        //                 .eraseToAnyPublisher()
        //         }
        //     }
        //     .retry(3)
        //     .replaceError(with: [])
        //     .receive(on: RunLoop.main)
//            .assign(to: \.mergeRequests, on: self)
//            .store(in: &scope)

        // print(result)
    }
}
