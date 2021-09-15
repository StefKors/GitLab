//
//  ContentView.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var networkManager = NetworkManager()
    @Environment(\.openURL) var openURL

    var dateValue: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: networkManager.lastUpdate)
    }
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 10) {
                ScrollView {
                    ForEach(networkManager.mergeRequests, id: \.id) { MR in
                        VStack {
                            // MARK: - Top Part
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(MR.title ?? "untitled")
                                        .fontWeight(.bold)

                                    HStack(spacing: 5) {
                                        Text(MR.references?.short ?? "")
                                            .foregroundColor(.accentColor)
                                        Text("Created by")
                                        Text(MR.author?.name ?? "")
                                            .foregroundColor(.accentColor)
                                    }
                                }

                                Spacer()
                                VStack(alignment:.trailing) {
                                    HStack {
                                        if MR.mergeStatus != MergeStatus.canBeMerged {
                                            NeedsReviewIcon()
                                        }
                                        CommentIcon(count: MR.userNotesCount)
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(.accentColor)
                                            .font(.system(size: 18))
                                    }

                                    //                        "checkmark.circle"
                                    //                        "xmark.circle"
                                }


                            }
                        }
                        .onTapGesture {
                            guard let id = MR.iid else {
                                return
                            }
                            let url = "https://gitlab.com/beamgroup/beam/-/merge_requests/\(id)"
                            openMR(url)
                        }
                        Divider()
                    }

                }
                Button("Query GitLab", action: {
                    networkManager.getMRs()
                })
                Text("Last updated at: \(dateValue)")
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
            .frame(maxWidth: 400, maxHeight: .infinity)
            .padding()
            .onAppear {
                networkManager.getMRs()
            }
        }
    }
    func openMR(_ target: String) {
        guard let url = URL(string: target) else {
            return
        }
        openURL(url)
    }

}


struct ContentView_Previews: PreviewProvider {
    static let taskStatus = TaskCompletionStatus(count: 0, completedCount: 0)
    static let reference = References(short: "!1279", relative: "!1279", full: "beamgroup/beam!1279")
    static let timeStat = TimeStats(timeEstimate: 0, totalTimeSpent: 0, humanTimeEstimate: 0, humanTotalTimeSpent: 0)
    static let author = Author(
        id: 12,
        name: "Gil Katz",
        username: "gil30",
        state: AuthorState(rawValue: "active")!,
        avatarURL: "https://secure.gravatar.com/avatar/c06ef01ee22139ad2f98470507267aa6?s=80&d=identicon",
        webURL: "https://gitlab.com/gil30"
    )
    static let mrs = [
        MergeRequestElement(
            id: 1,
            iid: 1,
            projectID: 1,
            title: "Gil/replacing clustering framework",
            mergeRequestDescription: "In this MR:\n\n1. html / markdown parsing is removed since it's not used and haven't been updated in a while\n2. the html parsing is cleaned up and split out into a HtmlNoteAdapter and HtmlVisitor class.\n3. the html is parsed to BeamElements directly to support images. (Previously it was parse to BeamText, making image support awkward)\n4. The filemanager and download manager can optionally be passed to the HtmlNoteAdapter. If included images will be downloaded and stored. If not included images will be omitted\n5. Base64 support is added, resolving BE-1751. This can be tested on UITests page 4\n6. PointAndShootHTMLTest.swift is removed as it's functionally duplicate to the HtmlNoteAdapter, now that the promises are removed.",
            state: MergeRequestState(rawValue: "opened")!,
            createdAt: "2021-09-13T17:13:48.094Z",
            updatedAt: "2021-09-13T17:13:48.094Z",
            mergedBy: author,
            mergedAt: "2021-09-13T17:13:48.094Z",
            closedBy: "2021-09-13T17:13:48.094Z",
            closedAt: "2021-09-13T17:13:48.094Z",
            targetBranch: TargetBranch(rawValue: "develop")!,
            sourceBranch: "gil/replacing-clustering-framework",
            userNotesCount: 0,
            upvotes: 0,
            downvotes: 0,
            author: author,
            assignees: [author],
            assignee: nil,
            reviewers: [],
            sourceProjectID: 22103425,
            targetProjectID: 22103425,
            labels: [],
            draft: false,
            workInProgress: false,
            milestone: nil,
            mergeWhenPipelineSucceeds: true,
            mergeStatus: MergeStatus(rawValue: "unchecked")!,
            sha: "6e2be81ad46d8865bbc93bd0fd58de01fa6ff19e",
            mergeCommitSHA: "6e2be81ad46d8865bbc93bd0fd58de01fa6ff19e",
            squashCommitSHA: "6e2be81ad46d8865bbc93bd0fd58de01fa6ff19e",
            discussionLocked: "null",
            shouldRemoveSourceBranch: nil,
            forceRemoveSourceBranch: true,
            reference: nil,
            references: reference,
            webURL: "http://gitlab.com",
            timeStats: timeStat,
            squash: true,
            taskCompletionStatus: taskStatus,
            hasConflicts: false,
            blockingDiscussionsResolved: true,
            approvalsBeforeMerge: nil,
            allowCollaboration: nil,
            allowMaintainerToPush: nil
        )
    ]
    static var previews: some View {
        ContentView()
    }
}




//        Button("Send Request", action: {
//            networkManager.name()
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000)) {
//                print("MRS", networkManager.mergeRequests)
//            }
//        })
