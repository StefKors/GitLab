//
//  CISuccessIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CISuccessIcon: View {
    var body: some View {
        Image(systemName: "checkmark.circle")
            .foregroundStyle(.green)
            .font(.system(size: 18))
            .help(String(localized: "CI Success"))
            .clipShape(Rectangle())
    }
}

struct CISuccessIcon_Previews: PreviewProvider {
    static var previews: some View {
        CISuccessIcon()
    }
}
