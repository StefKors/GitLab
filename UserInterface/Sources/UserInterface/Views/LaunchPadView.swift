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
                            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Color.accentColor)
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
