//
//  AdvancedSettingsView.swift
//  
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import Preferences
import Defaults

public struct AdvancedSettingsView: View {
    @ObservedObject public var model: NetworkManager
    @Default(.selectedIcon) public var selectedIcon

    public var body: some View {
        Settings.Container(contentWidth: 450.0) {
            Settings.Section(title: "Display as App Window") {
                Toggle(isOn: $model.showAppWindow) {
                    EmptyView()
                }
                .toggleStyle(.switch)
            }

            Settings.Section(title: "Show Dock Icon") {
                Toggle(isOn: $model.showDockIcon) {
                    EmptyView()
                }
                .toggleStyle(.switch)
            }

            Settings.Section(title: "Choose App Icon") {
                HStack(alignment: .top) {
                    ForEach(AppIcons.allCases, id: \.rawValue) { icon in
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(lineWidth: 2)
                                .fill(selectedIcon == icon ? Color.accentColor : .clear)
                            Image(icon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    let clockView = Image(icon.rawValue)
                                        .resizable()
                                        .scaledToFit()

                                    NSApp.dockTile.contentView = NSHostingView(rootView: clockView)
                                    NSApp.dockTile.display()
                                    selectedIcon = icon
                                }
                        }.frame(width: 60, height: 60)
                    }
                }
            }
        }
    }
}
