//
//  LastUpdateMessagePlaceholderView.swift
//  
//
//  Created by Stef Kors on 19/09/2022.
//

import SwiftUI

struct LastUpdateMessagePlaceholderView: View {
    var body: some View {
        Text("Last updated at: 19 September 2022 at 12:43")
            .opacity(0)
            .redacted(reason: .placeholder)
            .transition(.opacity.animation(.easeInOut(duration: 0.35).delay(0.2)))
            .foregroundColor(.gray)
            .font(.system(size: 10))
            .cornerRadius(5)
    }
}

struct LastUpdateMessagePlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        LastUpdateMessagePlaceholderView()
    }
}
