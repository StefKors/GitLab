//
//  CISkippedIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CISkippedIcon: View {
    var body: some View {
        Image(systemName: "chevron.right.circle")
            .foregroundColor(.secondary)
            .font(.system(size: 18))
    }
}

struct CISkippedIcon_Previews: PreviewProvider {
    static var previews: some View {
        CISkippedIcon()
    }
}
