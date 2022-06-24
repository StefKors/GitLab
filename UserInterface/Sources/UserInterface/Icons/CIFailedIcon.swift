//
//  CIFailedIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CIFailedIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.circle")
            .foregroundColor(.red)
            .font(.system(size: 18))
            .help("CI Failed")
    }
}

struct CIFailedIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIFailedIcon()
    }
}
