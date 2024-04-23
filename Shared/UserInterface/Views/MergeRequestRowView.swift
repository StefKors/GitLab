//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI



struct HorizontalMergeRequestSubRowView: View {
    var MR: MergeRequest

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let provider = MR.account?.provider {
                GitProviderView(provider: provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }

            AutoSizingWebLinks(MR: MR)

            Spacer()
            if let count = MR.userNotesCount, count > 1 {
                DiscussionCountIcon(count: count)
            }
            MergeStatusView(MR: MR)
            PipelineView(stages: MR.headPipeline?.stages?.edges?.map({ $0.node }) ?? [], instance: MR.account?.instance)
        }
    }
}

struct DoubleLineMergeRequestSubRowView: View {
    var MR: MergeRequest

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 4) {
                if let provider = MR.account?.provider {
                    GitProviderView(provider: provider)
                        .frame(width: 18, height: 18, alignment: .center)
                }

                AutoSizingWebLinks(MR: MR)

                Spacer()
            }

            HStack(alignment: .center, spacing: 4) {
                if let count = MR.userNotesCount, count > 1 {
                    DiscussionCountIcon(count: count)
                }
                MergeStatusView(MR: MR)
                PipelineView(stages: MR.headPipeline?.stages?.edges?.map({ $0.node }) ?? [], instance: MR.account?.instance)
            }
        }
    }
}

struct MergeRequestRowView: View {
    var MR: MergeRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl)
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
                .padding(.trailing)

            ViewThatFits {
                DoubleLineMergeRequestSubRowView(MR: MR)
                    .frame(minWidth: 50, idealWidth: 60, alignment: .leading)

                HorizontalMergeRequestSubRowView(MR: MR)
                    .frame(minWidth: 100, idealWidth: 120, alignment: .leading)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 50, content: {
        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview2)
        })
        .frame(width: 190)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview2)
        })
        .frame(width: 290)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview2)
        })
    })
    .scenePadding()
}

// Choose view based on widget family
//struct EmojiRangerWidgetEntryView: View {
//    var entry: SimpleEntry
//
//    @Environment(\.widgetFamily) var family
//
//    @ViewBuilder
//    var body: some View {
//        switch family {
//
//            // Code for other widget sizes.
//
//        case .systemLarge:
//            if #available(iOS 17.0, *) {
//                HStack(alignment: .top) {
//                    Button(intent: SuperCharge()) {
//                        Image(systemName: "bolt.fill")
//                    }
//                }
//                .tint(.white)
//                .padding()
//            }
//            // ...rest of view
//        }
//    }
//}

