//
//  AdvancedSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import Defaults
import UserNotifications

struct AppIconView: View {
    let isSelected: Bool
    let icon: AppIcons
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(lineWidth: 2)
                .fill(isSelected ? Color.accentColor : .clear)
            Image(icon.rawValue)
                .resizable()
                .scaledToFit()
        }.frame(width: 60, height: 60)
    }
}

public struct AdvancedSettingsView: View {
    @EnvironmentObject public var model: NetworkManager
    // @AppStorage("showAppWindow") var showAppWindow: Bool = false
    @AppStorage("appIcon") var selectedIcon: AppIcons = .DevIcon {
        didSet {
            let iconView = Image(selectedIcon.rawValue)
                .resizable()
                .scaledToFit()

            NSApp.dockTile.contentView = NSHostingView(rootView: iconView)
            NSApp.dockTile.display()
        }
    }

    public var body: some View {
#if os(macOS)
        Form {
            HStack {
                Text("Clear all Notifications")
                Spacer()
                Button("Clear", action: clearNotifications)
            }

            // Toggle(isOn: $showAppWindow) {
            //     Text("Display as App Window")
            // }
            // .toggleStyle(.switch)

            Picker(selection: $selectedIcon) {
                ForEach(AppIcons.allCases, id: \.rawValue) { icon in
                    AppIconView(isSelected: selectedIcon == icon, icon: icon)
                        .tag(icon)
                        .id(icon)
                }
            } label: {
                HStack {
                    Text("Choose Dock Icon")
                    Spacer()
                }
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()

        }.formStyle(.grouped)
#endif
    }

    func clearNotifications() {
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
                print("error? \(String(describing: error?.localizedDescription))")
            }
        } else {
            // Fallback on earlier versions
        }


    }
}
