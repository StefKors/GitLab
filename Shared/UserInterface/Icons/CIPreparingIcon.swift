//
//  CIPreparingIcon.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct CIPreparingIcon: View {
    var body: some View {
        Image(systemName: "circle.dotted")
            .foregroundStyle(.secondary)
            .font(.system(size: 16))
            .help(String(localized: "CI pipeline preparing"))
            .clipShape(Rectangle())
    }
}

struct CIPreparingIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIPreparingIcon()
    }
}
