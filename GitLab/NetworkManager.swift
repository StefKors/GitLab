//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    // https://gitlab.com/api/v4/projects/22103425/merge_requests?state=opened
    var url: URL = URL(string: "https://www.gitlab.com/api/v4/projects/22103425/merge_requests?state=opened")!
    var token: String = "Bearer DYjsR1sjWmsPBwBMdipb"
//    @Published var dataTask
    @Published var mergeRequests: [MergeRequestElement] = []
    private var scope: Set<AnyCancellable> = []

    func name() {
        // network call
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Authorization": token]

        let session = URLSession(configuration: sessionConfiguration)
        session.dataTaskPublisher(for: url)
            .map({ item in
                return item.data
            })
            .decode(type: [MergeRequestElement].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.mergeRequests, on: self)
            .store(in: &scope)

        print(scope)
    }
}
