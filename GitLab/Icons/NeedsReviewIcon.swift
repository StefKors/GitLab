//
//  NeedsReviewIcon.swift
//  NeedsReviewIcon
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct NeedsReviewIcon: View {
    var body: some View {
        Text("Needs Review")
            .font(.system(size: 11))
            .foregroundColor(.accentColor)
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 1)
            )

    }
}

struct NeedsReviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        NeedsReviewIcon()
            .padding()
    }
}
