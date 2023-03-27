//
//  MenubarContentView.swift
//  GitLab
//
//  Created by Stef Kors on 26/09/2022.
//

import SwiftUI
import UserInterface
import GitLabAPIService

struct MenubarContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @State var scene: ScenePhase?

    var body: some View {
        // if scene == .active {
        Button("click", action: handleClick)
            .scenePadding()
        // UserInterface()
        //     .onChange(of: scenePhase) { newPhase in
        //
        //         if newPhase == .active {
        //             print("Active")
        //         } else if newPhase == .inactive {
        //             print("Inactive")
        //         } else if newPhase == .background {
        //             print("Background")
        //         }
        //
        //         scene = newPhase
        //     }
        // }
    }

    func handleClick() {
        print("result running task")

        // To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:
        let connection = NSXPCConnection(serviceName: "com.stefkors.GitLabAPIService")
        connection.remoteObjectInterface = NSXPCInterface(with: GitLabAPIServiceProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? GitLabAPIServiceProtocol

        // Once you have a connection to the service, you can use it like this:

        print("got service")
        service!.uppercase(string: "hello") { aString in
            DispatchQueue.main.async {
                print("Result string was: \(aString)")
                connection.invalidate()
            }
        }

        // And, when you are finished with the service, clean up the connection like this:

    }
}

struct MenubarContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenubarContentView()
    }
}
