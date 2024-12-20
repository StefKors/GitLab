//
//  CIManualIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CIManualIcon: View {
    var body: some View {
        Image(systemName: "gearshape.circle")
            .foregroundStyle(.secondary)
            .font(.system(size: 16))
            .help(String(localized: "Manual CI step"))
            .clipShape(Rectangle())
    }
}

struct CiManualIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIManualIcon()
    }
}
