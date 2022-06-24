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
            .foregroundColor(.secondary)
            .font(.system(size: 18))
            .help("CI pipeline preparing")
    }
}

struct CIPreparingIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIPreparingIcon()
    }
}
