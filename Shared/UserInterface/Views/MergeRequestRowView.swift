//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct ProjectLink: View {
    let group: String?
    let project: String?
    let reference: String?

    let destination: URL?

    var long: String {
        [group, project, reference].compactMap({ $0 }).joined(separator: "/")
    }

    var medium: String {
        [project, reference].compactMap({ $0 }).joined(separator: "/")
    }

    var short: String {
        [reference].compactMap({ $0 }).joined(separator: "/")
    }



    var body: some View {
        ViewThatFits {
            WebLink(
                linkText: long,
                destination: destination
            )

            WebLink(
                linkText: medium,
                destination: destination
            )

            WebLink(
                linkText: short,
                destination: destination
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 320)

        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 170)

        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 40)
    }
    .scenePadding()
}

struct AutoSizingWebLinks: View {
    var MR: MergeRequest

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                WebLink(
                    linkText: "\(MR.targetProject?.group?.fullPath ?? "")/\(MR.targetProject?.path ?? "")/\(MR.reference ?? "")",
                    destination: MR.targetProject?.webURL
                )
            }
            .frame(minWidth: 50, idealWidth: 200, maxWidth: 400, alignment: .leading)

            HStack {
                WebLink(
                    linkText: "\(MR.targetProject?.path ?? "")/\(MR.reference ?? "")",
                    destination: MR.targetProject?.webURL
                )
            }
            .frame(minWidth: 50, idealWidth: 100, maxWidth: 400, alignment: .leading)

            HStack {
                WebLink(
                    linkText: "\(MR.reference ?? "")",
                    destination: MR.targetProject?.webURL
                )
            }
            .frame(minWidth: 50, idealWidth: 50, maxWidth: 400, alignment: .leading)
        }
        .frame(minWidth: 50, idealWidth: 320, maxWidth: 400, alignment: .leading)
    }
}


struct HorizontalMergeRequestSubRowView: View {
    var MR: MergeRequest

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let provider = MR.account?.provider {
                GitProviderView(provider: provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }

            AutoSizingWebLinks(MR: MR)

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
            .background(.red)

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

struct MergeRequestRowView: View {
    var MR: MergeRequest
    var macOSUI: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl)
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
                .padding(.trailing)

            ViewThatFits {
                HorizontalMergeRequestSubRowView(MR: MR)
                    .frame(minWidth: 180, idealWidth: 200, alignment: .leading)

                DoubleLineMergeRequestSubRowView(MR: MR)
                    .frame(minWidth: 50, idealWidth: 100, alignment: .leading)
            }
        }
    }

    var iOSUI: some View {
        HStack {
            VStack(alignment: .leading) {
                MergeStatusView(MR: MR).id(MR.id)
                MergeRequestLabelView(MR: MR)
            }
            Spacer()
            VStack(alignment:.trailing) {
                HStack {
                    if let count = MR.userNotesCount, count > 1 {
                        DiscussionCountIcon(count: count)
                    }
                    CIStatusView(status: MR.headPipeline?.status)
                }
            }
        }
    }

    var body: some View {
#if os(macOS)
        macOSUI
#else
        iOSUI
#endif
    }
}
