//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalScrollBounce() -> some View {
        if #available(macOS 13.3, *) {
            self
                .scrollBounceBehavior(.basedOnSize)
        }
        else {
            self
        }
    }
}

struct LaunchpadView: View {
    @StateObject var launchpadController: LaunchpadController
    @State private var repos: [LaunchpadRepo] = []

    @State private var selectedView: Int = 0

    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(repos.reversed(), id: \.id) { repo in
                    LaunchpadItem(repo: repo)
                }
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .conditionalScrollBounce()
        .padding(.leading)
        // .onReceive(launchpadController.$contributedRepos.$items, perform: {
        //     // We can even create complex pipelines, for example filtering all notes bigger than a tweet
        //     self.repos = $0
        // })
    }
}
