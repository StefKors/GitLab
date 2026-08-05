//
//  DesktopWidgetToolBundle.swift
//  DesktopWidgetTool
//
//  Created by Stef Kors on 06/03/2024.
//

import WidgetKit
import SwiftUI
import GRDB
import SQLiteData
import OSLog

@main
struct DesktopWidgetToolBundle: WidgetBundle {

    init() {
        
    }

    var body: some Widget {
        ReviewRequestedMergeRequestWidget()
        AuthoredMergeRequestWidget()

        LaunchPadWidget()
    }
}
