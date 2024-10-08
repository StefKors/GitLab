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
            }
        }
    }
}

#Preview {
    GitProviderView(provider: .GitLab)
}
