//
//  CISuccessIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CISuccessIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(systemName: "checkmark.circle")
            .foregroundStyle(.green.mix(with: .black, by: colorScheme == .dark ? 0 : 0.2))
            .font(.system(size: 16))
            .help(String(localized: "CI Success"))
            .clipShape(Rectangle())
    }
}

struct CISuccessIcon_Previews: PreviewProvider {
    static var previews: some View {
        CISuccessIcon()
    }
}
