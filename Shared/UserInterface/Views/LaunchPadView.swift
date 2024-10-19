//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI

struct LaunchpadView: View {
    let repos: [LaunchpadRepo]

    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(repos.reversed(), id: \.id) { repo in
                    LaunchpadItem(repo: repo)
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
