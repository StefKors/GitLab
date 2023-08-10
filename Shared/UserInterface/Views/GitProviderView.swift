//
//  GitProviderView.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI

struct GitProviderView: View {
    let provider: GitProvider
    var body: some View {
        switch provider {
        case .GitLab:
            Image("GitLab-Outline")
        }
    }
}

#Preview {
    GitProviderView(provider: .GitLab)
}
