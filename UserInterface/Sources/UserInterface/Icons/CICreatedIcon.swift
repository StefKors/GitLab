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
            .foregroundColor(.secondary)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: 18))
            .help("CI Created")
    }
}

struct CICreatedIcon_Previews: PreviewProvider {
    static var previews: some View {
        CICreatedIcon()
    }
}
