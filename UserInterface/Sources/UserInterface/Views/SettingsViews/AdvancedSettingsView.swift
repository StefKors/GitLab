//
//  AdvancedSettingsView.swift
//  
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import Defaults
import UserNotifications

public struct AdvancedSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    public var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                VStack {
                    HStack {
                        Text("Clear all Notifications")
                        Spacer()
                        Button("Clear", action: {
                            let notifs = UNUserNotificationCenter.current()
                            notifs.getDeliveredNotifications { delivereds in
                                for delivered in delivereds {
                                    print("has delivered notif \(delivered.description)")
                                }
                            }

                            notifs.getPendingNotificationRequests { pendings in
                                for pending in pendings {
                                    print("has pending notif \(pending.description)")
                                }
                            }

                            notifs.removeAllDeliveredNotifications()
                            if #available(macOS 13.0, *) {
                                notifs.setBadgeCount(0) { error in
                                    print("error? \(error?.localizedDescription)")
                                }
                            } else {
                                // Fallback on earlier versions
                            }


                        })
                    }

                    HStack {
                        Text("Display as App Window")
                        Spacer()
                        Toggle(isOn: $model.showAppWindow) {
                            EmptyView()
                        }
                        .toggleStyle(.switch)
                    }
                }.padding()
            }

            // GroupBox {
            //     HStack {
            //         Text("Show Dock Icon")
            //         Toggle(isOn: $model.showDockIcon) {
            //             EmptyView()
            //         }
            //         .toggleStyle(.switch)
            //         Spacer()
            //     }.padding()
            // }
#if os(macOS)
            GroupBox {
                HStack {
                    Text("Choose Dock Icon")
                    Spacer()
                    HStack(alignment: .top) {
                        ForEach(AppIcons.allCases, id: \.rawValue) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 2)
                                    .fill(model.selectedIcon == icon ? Color.accentColor : .clear)
                                Image(icon.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .onTapGesture {
                                        let clockView = Image(icon.rawValue)
                                            .resizable()
                                            .scaledToFit()

                                        NSApp.dockTile.contentView = NSHostingView(rootView: clockView)
                                        NSApp.dockTile.display()
                                        model.selectedIcon = icon
                                    }
                            }.frame(width: 60, height: 60)
                        }
                    }
                }.padding()
            }
#endif
        }.padding()
    }
}
