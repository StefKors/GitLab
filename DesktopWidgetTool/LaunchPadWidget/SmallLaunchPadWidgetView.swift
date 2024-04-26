//
//  SmallLaunchPadWidgetView.swift
//  DesktopWidgetToolExtension
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct SmallLaunchPadWidgetView: View {
    let repos: [LaunchpadRepo]

    var body: some View {
        WrappingHStack {
            ForEach(repos.prefix(9), id: \.id) { repo in
                LaunchpadImage(repo: repo)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    SmallLaunchPadWidgetView(repos: [])
}
