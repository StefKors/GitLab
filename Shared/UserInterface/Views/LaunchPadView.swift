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
        .scrollIndicators(.hidden)
        .conditionalScrollBounce()
        .padding(.leading)
    }
}
