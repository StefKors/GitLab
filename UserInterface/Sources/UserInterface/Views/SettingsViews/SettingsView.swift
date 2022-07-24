//
//  SettingsView.swift
//  
//
//  Created by Stef Kors on 21/07/2022.
//

// import SwiftUI
import Cocoa
import Preferences

public extension Settings.PaneIdentifier {
    static let account = Self("account")
    static let advanced = Self("advanced")
}

/**
 Function wrapping SwiftUI into `SettingsPane`, which is mimicking view controller's default construction syntax.
 */
public func AccountSettingsViewController(model: NetworkManager) -> SettingsPane {
    /**
     Wrap your custom view into `Settings.Pane`, while providing necessary toolbar info.
     */
    let paneView = Settings.Pane(
        identifier: .account,
        title: "Account",
        toolbarIcon: NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Accounts settings")!
    ) {
        AccountSettingsView(model: model)
    }

    return Settings.PaneHostingController(pane: paneView)
}

public func AdvancedSettingsViewController(model: NetworkManager)  -> SettingsPane {
    /**
     Wrap your custom view into `Settings.Pane`, while providing necessary toolbar info.
     */
    let paneView = Settings.Pane(
        identifier: .advanced,
        title: "Advanced",
        toolbarIcon: NSImage(systemSymbolName: "gearshape.2.fill", accessibilityDescription: "Accounts settings")!
    ) {
        AdvancedSettingsView(model: model)
    }

    return Settings.PaneHostingController(pane: paneView)
}
