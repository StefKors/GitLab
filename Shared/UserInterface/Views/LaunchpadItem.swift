//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI

struct LaunchpadItem: View {
    var repo: LaunchpadRepo

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var isHovering = false

    var body: some View {
//        Button {
//            // TODO:
//            print("todo: set filter")
//        } label: {
            HStack() {
                LaunchpadImage(repo: repo)

                VStack(alignment: .leading) {
                    Text(repo.name)
                    Text(repo.group)
                        .foregroundColor(.secondary)
                }

                Button {
                    openURL(repo.url)
                    dismissWindow()
                } label: {
                    Label("Open on Web", systemImage: "arrow.up.forward")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.menubar)
            }
//        }.buttonStyle(.shaded)
    }
}

#Preview {
    LaunchpadItem(repo: .preview)
        .scenePadding()
}
