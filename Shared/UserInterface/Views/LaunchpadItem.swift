//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI
import CachedAsyncImage

struct LaunchpadImage: View {
    let repo: LaunchpadRepo

    var body: some View {
        HStack {
            if let image = repo.image {
#if os(macOS)
                Image(nsImage: NSImage(data: image)!)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .shadow(radius: 3)
#else
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .shadow(radius: 3)
#endif
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.secondary)
                    .shadow(radius: 3)
                    .overlay(content: {
                        if let char = repo.name.first {
                            Text(String(char).capitalized)
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                                .colorInvert()
                        }
                    })
                    .padding(2)
            }
        }
        .frame(width: 32.0, height: 32.0)
    }
}

struct LaunchpadItem: View {
    var repo: LaunchpadRepo

    @Environment(\.openURL) private var openURL
    @State private var isHovering = false

    var body: some View {
        HStack() {
            LaunchpadImage(repo: repo)

            VStack(alignment: .leading) {
                Text(repo.name)
                    .foregroundColor(isHovering ? .accentColor  : .primary)
                Text(repo.group)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.interactiveSpring(), value: isHovering)
        .onTapGesture {
            openURL(repo.url)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
