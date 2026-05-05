//
//  LastUpdateMessageView.swift
//
//
//  Created by Stef Kors on 26/07/2022.
//

import SwiftUI

struct LastUpdateMessageView: View {

    @Environment(\.openSettings) var openSetting
    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                Spacer()

#if os(macOS)
                if #available(macOS 14.0, *) {
                    Button(action: openSettings) {
                        SwiftUI.Label("Settings", systemImage: "gear")
                    }
                    .buttonStyle(.menubar)
                } else {
                    Button(action: openSettings, label: {
                        SwiftUI.Label("Settings", systemImage: "gear")
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
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
//            .padding(.top, 4)
        }
        .background(.thinMaterial)
    }

    func openSettings() {
        openSetting()
// #if os(macOS)
//         if #available(macOS 13.0, *) {
//             // Private API - must use string-based selector
//             NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
//         } else {
//             // Private API - must use string-based selector
//             NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
//         }
// #endif
    }

    func quitApp() {
#if os(macOS)
        NSApplication.shared.terminate(nil)
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
