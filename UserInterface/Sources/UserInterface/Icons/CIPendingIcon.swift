//
//  CIPendingIcon.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct CIPendingIcon: View {
    var body: some View {
        Image(systemName: "pause.circle")
            .foregroundColor(.secondary)
            .font(.system(size: 18))
            .help("CI pipeline pending")
    }
}

struct CIPendingIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIPendingIcon()
    }
}
