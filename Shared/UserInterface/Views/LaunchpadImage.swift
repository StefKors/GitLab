//
//  LaunchpadImage.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//


import SwiftUI

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

#Preview {
    LaunchpadImage(repo: .preview)
        .scenePadding()
}
