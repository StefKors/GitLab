//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI


struct LaunchpadView: View {
    public var repos: Set<LaunchpadRepo>

    var body: some View {
        HStack() {
            ForEach(repos.map { $0 }, id: \.id) { repo in
                LaunchpadItem(repo: repo)
            }
            Spacer()
        }
        .padding(.leading)
    }
}
