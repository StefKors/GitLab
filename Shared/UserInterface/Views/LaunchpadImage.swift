//
//  LaunchpadImage.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation
import SwiftUI
import NukeUI
import Nuke

struct LaunchpadImage: View {
    let repo: LaunchpadRepo

    private var url: URL? {
        if let image = repo.image {
            return URL(string: "data:image/png;base64," + image.base64EncodedString())
        } else if let imageURL = repo.imageURL {
            return imageURL
        } else {
            return nil
        }
    }

    private let providerCircleSize: CGFloat = 14

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.generateHSLColor(for: repo.name))
            .overlay(content: {
                if let char = repo.name.first {
                    Text(String(char).capitalized)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                        .colorInvert()
                }
            })
            .padding(2)
    }

    var body: some View {
        HStack {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .transition(.opacity.combined(with: .scale).combined(with: .blurReplace))
                        .mask {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .padding(2)
                        }
                } else {
                    placeholder
                }
            }
        }
        .frame(width: 32.0, height: 32.0)
        .if(
            repo.provider != nil,
            transform: { content in
                content
                    .mask({
                        Rectangle()
                            .fill(.white)
                            .overlay(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(.black)
                                    .frame(width: providerCircleSize, height: providerCircleSize, alignment: .center)
                            }
                            .compositingGroup()
                            .luminanceToAlpha()
                    })
                    .overlay(alignment: .bottomTrailing) {
                        if let provider = repo.provider {
                            Circle()
                                .fill(.clear)
                                .frame(width: providerCircleSize, height: providerCircleSize, alignment: .center)
                                .overlay {
                                    GitProviderView(provider: provider)
                                }
                        }
                    }
            })
        .shadow(radius: 3)

    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.adaptive(minimum: 42), alignment: .leading)
    ], alignment: .leading, spacing: 10) {
        ForEach(0...26, id: \.self) { letter in
            LaunchpadImage(repo: LaunchpadRepo(
                id: "uuid",
                name: UUID().uuidString,
                image: .previewRepoImage,
                group: "StefKors",
                url: URL(string: "https://gitlab.com/stefkors/swiftui-launchpad")!,
                provider: .GitHub,
                hasUpdatedSinceLaunch: false
            ))
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .scenePadding()
}
