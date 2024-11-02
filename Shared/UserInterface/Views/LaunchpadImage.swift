//
//  LaunchpadImage.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

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

    var body: some View {
        HStack {
            if let url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .transition(.opacity.combined(with: .scale).combined(with: .blurReplace))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.secondary)
                        .shadow(radius: 3)
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
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.secondary)
                    .shadow(radius: 3)
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
        }
        .frame(width: 32.0, height: 32.0)
        .if(repo.provider != nil, transform: { content in
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

    }
}

#Preview {
    LaunchpadImage(repo: .preview)
        .scenePadding()
}
