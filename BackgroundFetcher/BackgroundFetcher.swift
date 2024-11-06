//
//  BackgroundFetcher.swift
//  BackgroundFetcher
//
//  Created by Stef Kors on 03/11/2024.
//

import Foundation
import OSLog
import SwiftData
/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class BackgroundFetcher: NSObject, BackgroundFetcherProtocol {
    let log = Logger()

//    var helloWorldTimer = Timer.scheduledTimer(
//        timeInterval: 6.0,
//        target: BackgroundFetcher.self,
//        selector: #selector(Self.sayHello),
//        userInfo: nil,
//        repeats: true
//    )
//
//    @objc func sayHello() {
//        print("hello World")
//        log.warning("Jenga 5 (success say hello)")
//    }
//
//    var timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
//        (_) in
//        let log2 = Logger()
//        log2.warning("Jenga 2 (simple timer)")
//    }

    let activity = NSBackgroundActivityScheduler(identifier: "com.stefkors.GitLab.updatecheck")

    var count: Int = 0
    var date = Date.now


    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    @objc func performCalculation(firstNumber: Int, secondNumber: Int) {
        let response = firstNumber + secondNumber
        print("response: \(response)")
        if count == 0 {
            startBackground()
        }
//        log.warning("Jenga 3 performCalc")
//        timer.fire()
//        activity.invalidate()
//        activity.repeats = true
//        activity.interval = 2 // seconds
//        activity.tolerance = 0
//        activity.qualityOfService = .userInteractive
////        print("hi 2")
////        log.warning("Jenga 4")
//        activity.schedule { completion in
//            // perform activity
//            let newDate = Date.now
//            self.log.warning("Jenga 5 (success performCalc) \(response) \(self.count.description) sinceLast: \(newDate.timeIntervalSince(self.date)) seconds")
//            self.count += 1
//            self.date = Date.now
//            completion(.finished)
//        }
    }

    func startBackground() {
        activity.invalidate()
        activity.repeats = true
        activity.interval = 8 // seconds
        activity.tolerance = 1
        activity.qualityOfService = .userInteractive
        //        print("hi 2")
        //        log.warning("Jenga 4")
        activity.schedule { completion in

            let context = ModelContext(.shared)

            // WORKS!
//            let repo = LaunchpadRepo(
//                id: UUID().uuidString,
//                name: "Test Repo \(self.count.description)",
//                group: "Apple",
//                url: URL(string: "https://google.com")!,
//                provider: .GitHub
//            )
//            context.insert(repo)
//            try? context.save()

            let newDate = Date.now
                let interval = newDate.timeIntervalSince(self.date)
            if interval < self.activity.interval {
                return completion(.finished)
            }
            self.log.warning("Jenga 5 (success performCalc) \(self.count.description) sinceLast: \(interval) seconds shoulddefered? \(self.activity.shouldDefer)")
            self.count += 1
            self.date = Date.now
            completion(.finished)
        }
    }

    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    @objc func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void) {
        let response = firstNumber + secondNumber
        reply(response)
    }
}
