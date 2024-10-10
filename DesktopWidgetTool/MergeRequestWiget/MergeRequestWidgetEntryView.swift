//
//  MergeRequestWidgetEntryView.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI
import WidgetKit

struct MergeRequestWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) private var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemExtraLarge:
            ExtraLargeMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests,
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemLarge:
            LargeMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests,
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemMedium:
            MediumMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests
//                accounts: entry.accounts,
//                repos: entry.repos,
//                selectedView: entry.selectedView
            )

        default:
//            SmallLaunchPadWidgetView(repos: entry.repos)
            VStack {
                Text("default widget view")
            }
        }
    }
}

#Preview {
    MergeRequestWidgetEntryView(entry: .preview)
}
