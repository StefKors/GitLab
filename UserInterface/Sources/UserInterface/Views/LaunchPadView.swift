//
//  LaunchpadView.swift
//  
//
//  Created by Stef Kors on 16/09/2022.
//

import SwiftUI
import Defaults
import CachedAsyncImage

struct LaunchpadView: View {
    public var repos: Set<LaunchpadRepo>

    var body: some View {
        HStack() {
            ForEach(repos.map { $0 }, id: \.id) { repo in
                HStack() {
                    HStack {
                        if let image = repo.image {
                            Image(nsImage: NSImage(data: image)!)
                                .resizable()
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
                        Text(repo.group)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.leading)
    }
}
