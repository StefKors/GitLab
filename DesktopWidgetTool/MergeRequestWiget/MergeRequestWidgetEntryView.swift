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
                mergeRequests: entry.mergeRequests.filter({ $0.type == entry.selectedView}),
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemLarge:
            LargeMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests.filter({ $0.type == entry.selectedView}),
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )

        case .systemMedium:
            MediumMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests.filter({ $0.type == entry.selectedView}),
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )
        case .systemSmall:
            MediumMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests.filter({ $0.type == entry.selectedView}),
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )
        @unknown default:
            MediumMergeRequestWidgetInterface(
                mergeRequests: entry.mergeRequests.filter({ $0.type == entry.selectedView}),
                accounts: entry.accounts,
                repos: entry.repos,
                selectedView: entry.selectedView
            )
        }
    }
}

#Preview {
    MergeRequestWidgetEntryView(entry: .preview)
}
