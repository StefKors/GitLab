//
//  CIScheduledIcon.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct CIScheduledIcon: View {
    var body: some View {
        Image(systemName: "clock.circle")
            .foregroundColor(.primary)
            .font(.system(size: 18))
            .help(String(localized: "CI pipeline scheduled"))
            .clipShape(Rectangle())
    }
}

struct CIScheduledIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIScheduledIcon()
    }
}
