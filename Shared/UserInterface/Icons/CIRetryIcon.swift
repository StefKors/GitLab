//
//  CIRetryIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CIRetryIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.arrow.circlepath")
            .foregroundStyle(.red)
            .font(.system(size: 16))
            .help(String(localized: "Retry CI pipeline"))
            .clipShape(Rectangle())
    }
}

struct CIRetryIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIRetryIcon()
    }
}
