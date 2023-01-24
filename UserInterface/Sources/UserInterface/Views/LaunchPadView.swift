//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI

struct LaunchpadView: View {
    @StateObject var launchpadController: LaunchpadController
    @State private var repos: [LaunchpadRepo] = []

    @State private var selectedView: Int = 0

    var body: some View {
        HStack() {
            ForEach(repos, id: \.id) { repo in
                LaunchpadItem(repo: repo)
            }
            Spacer()
        }
        .padding(.leading)
        .onReceive(launchpadController.$contributedRepos.$items, perform: {
            // We can even create complex pipelines, for example filtering all notes bigger than a tweet
            self.repos = $0
        })
    }
}
