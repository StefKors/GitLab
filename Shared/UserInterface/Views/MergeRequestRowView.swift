//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestRowView: View {
    var MR: MergeRequest
    var macOSUI: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl)
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
                .padding(.trailing)

            HStack(alignment: .center, spacing: 4) {
                if let provider = MR.account?.provider {
                    GitProviderView(provider: provider)
                        .frame(width: 18, height: 18, alignment: .center)
                }

                WebLink(
                    linkText: "\(MR.targetProject?.group?.fullPath ?? "")/\(MR.targetProject?.path ?? "")\(MR.reference ?? "")",
                    destination: MR.targetProject?.webURL
                )
                Spacer()
                if let count = MR.userNotesCount, count > 1 {
                    DiscussionCountIcon(count: count)
                }
                MergeStatusView(MR: MR)
                PipelineView(stages: MR.headPipeline?.stages?.edges?.map({ $0.node }) ?? [], instance: MR.account?.instance)
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
