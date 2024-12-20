//
//  CICreatedIcon.swift
//  
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

struct CICreatedIcon: View {
    var body: some View {
        Image(systemName: "smallcircle.filled.circle")
            .foregroundStyle(.secondary)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: 16))
            .help(String(localized: "CI Created"))
            .clipShape(Rectangle())
    }
}

struct CICreatedIcon_Previews: PreviewProvider {
    static var previews: some View {
        CICreatedIcon()
    }
}
