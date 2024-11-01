//
//  CICanceledIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CICanceledIcon: View {
    var body: some View {
        Image(systemName: "circle.slash")
            .foregroundStyle(.gray)
            .font(.system(size: 16))
            .help(String(localized: "CI canceled"))
            .clipShape(Rectangle())
    }
}

struct CICanceledIcon_Previews: PreviewProvider {
    static var previews: some View {
        CICanceledIcon()
    }
}
