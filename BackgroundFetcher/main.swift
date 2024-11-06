//
//  main.swift
//  BackgroundFetcher
//
//  Created by Stef Kors on 03/11/2024.
//

import Foundation
import OSLog

class ServiceDelegate: NSObject, NSXPCListenerDelegate {

//    var timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
//        (_) in
//        let log2 = Logger()
//        log2.warning("Jenga 5 (simple timer service delegate)")
//    }

    /// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        // Configure the connection.
        // First, set the interface that the exported object implements.
        newConnection.exportedInterface = NSXPCInterface(with: BackgroundFetcherProtocol.self)

        // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
        let exportedObject = BackgroundFetcher()
        newConnection.exportedObject = exportedObject
        
        // Resuming the connection allows the system to deliver more incoming messages.
        newConnection.resume()

//        timer.fire()

        // Returning true from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call invalidate() on the connection and return false.
        return true
    }
}

//var timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
//    (_) in
//    let log2 = Logger()
//    log2.warning("Jenga 5 (simple timer from main xpc)")
//}
//timer.fire()
// Create the delegate for the service.
let delegate = ServiceDelegate()

// Set up the one NSXPCListener for this service. It will handle all incoming connections.
let listener = NSXPCListener.service()
listener.delegate = delegate

// Resuming the serviceListener starts this service. This method does not return.
listener.resume()
