//
//  MenubarContentView.swift
//  GitLab
//
//  Created by Stef Kors on 26/09/2022.
//

import SwiftUI
import UserInterface
import Preferences

struct MenubarContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @State var scene: ScenePhase?

    var body: some View {
        // if scene == .active {
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
        // }
    }
}

struct MenubarContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenubarContentView()
    }
}
