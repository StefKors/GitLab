//
//  LaunchpadItem.swift
//  
//
//  Created by Stef Kors on 21/11/2022.
//

import SwiftUI
import Defaults
import CachedAsyncImage

struct LaunchpadItem: View {
    var repo: LaunchpadRepo

    @Environment(\.openURL) private var openURL
    @State private var isHovering = false

    var body: some View {
        HStack() {
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
                                Text(String(char))
                                    .font(.headline.bold())
                                    .foregroundColor(.primary)
                                    .colorInvert()
                            }
                        })
                        .padding(2)
                }
            }
            .frame(width: 32.0, height: 32.0)
            VStack(alignment: .leading) {
                Text(repo.name)
                    .foregroundColor(isHovering ? .accentColor  : .primary)
                Text(repo.group)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.interactiveSpring(), value: isHovering)
        .onTapGesture {
            print(repo)
            openURL(repo.url)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
