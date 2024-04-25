//
//  LastUpdateMessageView.swift
//
//
//  Created by Stef Kors on 26/07/2022.
//

import SwiftUI

struct LastUpdateMessageView: View {
    let lastUpdate: Date
    @Binding var networkState: NetworkState
    private let initialTimeRemaining = 10
    @State private var isHovering: Bool = false
    @State private var timeRemaining = 10
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var dateValue: String? {
//        guard let date = lastUpdate else {
//            return nil
//        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: lastUpdate)
    }

    var body: some View {
        HStack {
            if let date = dateValue {
                Text("Last updated at: \(date)")
                    .transition(.opacity.animation(.easeInOut(duration: 0.35).delay(0.2)))
                    .foregroundColor(.gray)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }

                        if timeRemaining <= 0 {
                            timeRemaining = initialTimeRemaining
                            networkState = .fetching
                        }
                    }
            } else {
                LastUpdateMessagePlaceholderView()
            }

            Spacer()

#if os(macOS)
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Label("Settings", systemImage: "gear")
                }
            } else {
                Button(action: openSettings, label: {
                    Label("Settings", systemImage: "gear")
                })
            }
            Button(action: quitApp, label: {
                Text("Quit")
            })
#endif
        }
        .font(.system(size: 10))
        .padding()
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
        LastUpdateMessageView(lastUpdate: Date.now, networkState: .constant(.idle))
    }
}
