//
//  GitProviderView.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI

struct GitProviderView: View {
    let provider: GitProvider?
    var body: some View {
        if let provider {
            switch provider {
            case .GitLab:
                Image("GitLab-Outline")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .GitHub:
                Image("Github-Outline")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(2)
            }
        }
    }
}

#Preview {
    HStack {
        GitProviderView(provider: .GitLab)
        GitProviderView(provider: .GitHub)
    }
    .frame(width: 100, height: 20)
    .scenePadding()
}
