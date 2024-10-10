//
//  LaunchPadWidgetEntryView.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI
import WidgetKit

struct LaunchPadWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallLaunchPadWidgetView(repos: entry.repos)

        case .systemMedium:
            MediumLaunchPadWidgetView(repos: entry.repos)

        default:
            VStack {
                Text("default widget view")
            }
        }
    }
}

#Preview {
    LaunchPadWidgetEntryView(entry: .preview)
}
