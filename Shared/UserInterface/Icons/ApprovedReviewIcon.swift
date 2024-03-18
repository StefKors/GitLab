//
//  ApprovedReviewIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct ApprovedReviewIcon: View {
    var approvedBy: [Author]

    @AppStorage("baseURL") private var baseURL: String = "https://gitlab.com"

    var largeView: some View {
        HStack {
            Text("Approved")
            HStack(spacing: -4) {
                ForEach(approvedBy, id: \.id, content: { author in
                    if let username = author.username,
                       let avatarUrl = author.avatarUrl,
                       let baseURL = URL(string: baseURL),
                       let url = URL(string: avatarUrl.absoluteString, relativeTo: baseURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 14, height: 14)
                        .help(username)
                    }
                })
            }
        }
        .font(.system(size: 11))
        .foregroundColor(.green)
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 2)
                .opacity(0.3)
        )
        .padding(1)
        .help("Merge request approved")
    }

    var smallView: some View {
            Image(systemName: "checkmark.circle")
            .symbolRenderingMode(.hierarchical)
                .foregroundColor(.green)
                .font(.system(size: 18))
                .help("Merge request approved")
                .clipShape(Rectangle())
//        .frame(width: 20, height: 20)
    }

    var body: some View {
        ViewThatFits {
            largeView

            smallView
        }

    }
}

// struct ApprovedReviewIcon_Previews: PreviewProvider {
//     static let networkManager = NetworkManager()
//     static var previews: some View {
//         ApprovedReviewIcon(approvedBy: [Author(id: "id", name: "Nicolas Cage", username: "cage2000", avatarUrl: URL(string: "/uploads/-/system/user/avatar/8609834/avatar.png")!)])
//             .environmentObject(self.networkManager)
//             .environmentObject(self.networkManager.noticeState)
//     }
// }
