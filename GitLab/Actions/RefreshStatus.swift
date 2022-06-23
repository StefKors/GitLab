//
//  RefreshStatus.swift
//  RefreshStatus
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct RefreshStatus: View {
    var isVisible: Bool
    var body: some View {
        HStack {
            CIProgressIcon()
            Text("updating")
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 20)
        )
        .animation(.easeInOut)
        .opacity(isVisible ? 1 : 0)
        .offset(x: 0, y: isVisible ? 0 : 5)
        .animation(.easeInOut)
    }
}

struct RefreshStatus_Previews: PreviewProvider {
    static var previews: some View {
        RefreshStatus(isVisible: true)
            .padding()
    }
}
