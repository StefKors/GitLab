//
//  CIWarningIcon.swift
//  GitLab
//
//  Created by Stef Kors on 08/10/2024.
//

import SwiftUI

struct CIWarningIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.circle")
            .foregroundStyle(.orange)
            .font(.system(size: 16))
            .help(String(localized: "CI Warning"))
            .clipShape(Rectangle())
    }
}

struct CIWarningIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIWarningIcon()
    }
}
