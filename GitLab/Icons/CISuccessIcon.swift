//
//  CISuccessIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CISuccessIcon: View {
    var body: some View {
        Image(systemName: "checkmark.circle")
            .foregroundColor(.accentColor)
            .font(.system(size: 18))
    }
}

struct CISuccessIcon_Previews: PreviewProvider {
    static var previews: some View {
        CISuccessIcon()
    }
}
