//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI

struct LaunchpadView: View {
    let launchpadItems: [LaunchpadItemModel]
    @Binding var activeRepoUrl: URL?

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(launchpadItems) { item in
                    LaunchpadItem(model: item, activeRepoUrl: $activeRepoUrl)
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
