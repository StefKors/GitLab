//
//  SettingsState.swift
//  GitLab
//
//  Created by Stef Kors on 13/11/2024.
//


import SwiftUI
import SwiftData

class SettingsState: ObservableObject {
    @AppStorage("Settings.showShareButton") var showShareButton: Bool = true

    @AppStorage("Settings.requestLanguage") var requestLanguage: RequestLanguageType = .auto
    var language: RequestLanguageType {
        let context = ModelContext(.shared)
        let accounts = (try? context.fetch(FetchDescriptor<Account>(sortBy: [.init(\.createdAt, order: .reverse)]))) ?? []
        switch requestLanguage {
        case .auto:
            if let firstAccount = accounts.first {
                switch firstAccount.provider {
                case .GitHub:
                    return .pullRequest
                case .GitLab:
                    return .mergeRequest
                }
            }
            return .mergeRequest
        default:
            return requestLanguage
        }
    }

    @Published private var isSettingActivationPolicy: Bool = false
    @AppStorage("Settings.activationPolicy") var activationPolicy: Bool = false {
        didSet {
            let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy ? .regular : .accessory
            //            activationPolicy = newActivationPolicy

            print("newValue \(newActivationPolicy)")
            NSApplication.shared.setActivationPolicy(newActivationPolicy)
            /// After setting `.accessory` mode the app is deactivating itself, so we need to make it active again.
            if newActivationPolicy == .accessory {
                NSApp.activate()
            }
        }
    }
}
