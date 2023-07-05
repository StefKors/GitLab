//
//  MenubarContentView.swift
//  GitLab
//
//  Created by Stef Kors on 26/09/2022.
//

import SwiftUI
import UserInterface

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
// 
// struct MenubarContentView_Previews: PreviewProvider {
//     static let networkManager = NetworkManager()
//     static var previews: some View {
//         MenubarContentView()
//             .environmentObject(self.networkManager)
//             .environmentObject(self.networkManager.noticeState)
//     }
// }
// 

struct BaseNoticeItem_Previews: PreviewProvider {
    static let networkManager = NetworkManager()
    static let informationNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: nil,
        type: .information
    )
    static let warningNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: 502,
        type: .warning
    )
    static let errorNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be",
        statusCode: 404,
        type: .error
    )
    static var previews: some View {
        VStack(spacing: 25) {
            BaseNoticeItem(notice: informationNotice)
            BaseNoticeItem(notice: warningNotice)
            BaseNoticeItem(notice: errorNotice)
        }
        .padding()
        .environmentObject(self.networkManager)
        .environmentObject(self.networkManager.noticeState)
    }
}
