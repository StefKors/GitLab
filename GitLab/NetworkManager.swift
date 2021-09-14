//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Combine

enum RequestError: Error {
    case sessionError(error: Error)
}

class NetworkManager: ObservableObject {
    // https://gitlab.com/api/v4/projects/22103425/merge_requests?state=opened
    var url: URL = URL(string: "https://www.gitlab.com/api/v4/projects/22103425/merge_requests?state=opened")!
    var token: String = "Bearer DYjsR1sjWmsPBwBMdipb"
    var lastUpdate: Date = NSDate.now
//    @Published var dataTask
    @Published var mergeRequests: [MergeRequestElement] = Mock.MRs {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                self.isUpdatingMRs = false
            }

        }
    }
    @Published var isUpdatingMRs: Bool = false
    private var scope: Set<AnyCancellable> = []

    func getMRs() {
        isUpdatingMRs = true

        // network call
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Authorization": token]

//        let session = URLSession(configuration: sessionConfiguration)
//        session.dataTaskPublisher(for: url)
//            .map({ item in
//                return item.data
//            })
//            .decode(type: [MergeRequestElement].self, decoder: JSONDecoder())
//            .catch { error -> AnyPublisher<[MergeRequestElement], Never> in
//                print(error)
//                if error is URLError {
//                    return Just([])
//                        .eraseToAnyPublisher()
//                } else {
//                    return Empty(completeImmediately: true)
//                        .eraseToAnyPublisher()
//                }
//            }
//            .retry(3)
////            .replaceError(with: [])
//            .receive(on: RunLoop.main)
//            .assign(to: \.mergeRequests, on: self)
//            .store(in: &scope)

        mergeRequests = Mock.MRs
    }
}
