//
//  WidgetLaunchPadRow.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct WidgetLaunchPadRow: View {
    let repos: [LaunchpadRepo]
    let length: Int
    var body: some View {
        HStack {
            ForEach(repos.prefix(length), id: \.id) { repo in
                LaunchpadItem(repo: repo)
            }
        }
        .frame(alignment: .leading)
    }
}

#Preview {
    WidgetLaunchPadRow(repos: [], length: 4)
}
