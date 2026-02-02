//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI

struct LaunchpadView: View {
    let repos: [LaunchpadRepo]
    @Binding var activeRepoUrl: URL?

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(repos, id: \.id) { repo in
                    LaunchpadItem(repo: repo, activeRepoUrl: $activeRepoUrl)
                }
                Spacer()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
//        .padding(.leading)
    }
}
