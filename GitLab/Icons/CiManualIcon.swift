//
//  CiManualIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CiManualIcon: View {
    var body: some View {
        Image(systemName: "play.circle")
            .foregroundColor(.secondary)
            .font(.system(size: 18))
            .help("Manual CI step")
    }
}

struct CiManualIcon_Previews: PreviewProvider {
    static var previews: some View {
        CiManualIcon()
    }
}
