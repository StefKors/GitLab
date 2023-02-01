//
//  AdvancedSettingsView.swift
//  
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import Defaults

public struct AdvancedSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    public var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                HStack {
                    Text("Display as App Window")
                    Toggle(isOn: $model.showAppWindow) {
                        EmptyView()
                    }
                    .toggleStyle(.switch)
                    Spacer()
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

            GroupBox {
                HStack {
                    Text("Choose Dock Icon")
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
                    Spacer()
                }.padding()
            }
        }.padding()
    }
}
