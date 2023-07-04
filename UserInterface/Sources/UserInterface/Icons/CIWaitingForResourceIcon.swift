//
//  CIWaitingForResourceIcon.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct CIWaitingForResourceIcon: View {
    var body: some View {
        Image(systemName: "circle.circle")
            .foregroundColor(.secondary)
            .font(.system(size: 18))
            .help("CI pipeline waiting for resources")
            .clipShape(Rectangle())
    }
}

struct CIWaitingForResourceIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIWaitingForResourceIcon()
    }
}
