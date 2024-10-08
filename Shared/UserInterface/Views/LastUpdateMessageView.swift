//
//  LastUpdateMessageView.swift
//
//
//  Created by Stef Kors on 26/07/2022.
//

import SwiftUI

struct LastUpdateMessageView: View {
    var body: some View {
        HStack {
            Spacer()

#if os(macOS)
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.menubar)
            } else {
                Button(action: openSettings, label: {
                    Label("Settings", systemImage: "gear")
                })
                .buttonStyle(.menubar)
            }
            Button(action: quitApp, label: {
                Text("Quit")
            })
            .buttonStyle(.menubar)
#endif
        }
        .font(.system(size: 10))
        .padding(.bottom)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    func openSettings() {
#if os(macOS)
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
#endif
    }

    func quitApp() {
#if os(macOS)
        NSApp.sendAction(Selector(("terminate:")), to: nil, from: nil)
#endif
    }
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

struct LastUpdateMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LastUpdateMessageView()
    }
}
