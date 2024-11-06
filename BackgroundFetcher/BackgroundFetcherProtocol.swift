//
//  BackgroundFetcherProtocol.swift
//  BackgroundFetcher
//
//  Created by Stef Kors on 03/11/2024.
//

import Foundation

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service.
@objc protocol BackgroundFetcherProtocol {
    func startFetching()
}

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     connectionToService = NSXPCConnection(serviceName: "com.stefkors.BackgroundFetcher")
     connectionToService.remoteObjectInterface = NSXPCInterface(with: BackgroundFetcherProtocol.self)
     connectionToService.resume()

 Once you have a connection to the service, you can use it like this:

     if let proxy = connectionToService.remoteObjectProxy as? BackgroundFetcherProtocol {
         proxy.performCalculation(firstNumber: ..., secondNumber: ...) { result in
             NSLog("Result of calculation is: \(result)")
         }
     }

 And, when you are finished with the service, clean up the connection like this:

     connectionToService.invalidate()
*/
