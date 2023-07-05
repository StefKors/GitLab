//
//  MenubarContentView.swift
//  GitLab
//
//  Created by Stef Kors on 26/09/2022.
//

import SwiftUI

struct MenubarContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var scene: ScenePhase?

    var body: some View {
        UserInterface()
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("Active")
                } else if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .background {
                    print("Background")
                }

                scene = newPhase
            }
    }
}

struct MenubarContentView_Previews: PreviewProvider {
    static let networkManager = NetworkManager()
    static var previews: some View {
        MenubarContentView()
            .environmentObject(self.networkManager)
            .environmentObject(self.networkManager.noticeState)
    }
}
