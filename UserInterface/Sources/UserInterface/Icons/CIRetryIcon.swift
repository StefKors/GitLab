//
//  CIRetryIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct CIRetryIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.arrow.circlepath")
            .foregroundColor(.red)
            .font(.system(size: 18))
            .help("Retry CI pipeline")
    }
}

struct CIRetryIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIRetryIcon()
    }
}
