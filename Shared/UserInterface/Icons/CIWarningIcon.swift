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
            .foregroundColor(.orange)
            .font(.system(size: 18))
            .help("CI Warning")
            .clipShape(Rectangle())
    }
}

struct CIWarningIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIWarningIcon()
    }
}