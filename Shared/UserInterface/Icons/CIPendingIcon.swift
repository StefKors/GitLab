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
            .foregroundStyle(Color(.displayP3, red: (217)/255, green: (123)/255, blue: (0)/255, opacity: 1))
            .font(.system(size: 16))
            .help(String(localized: "CI pipeline pending"))
            .clipShape(Rectangle())
    }
}

struct CIPendingIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIPendingIcon()
    }
}
