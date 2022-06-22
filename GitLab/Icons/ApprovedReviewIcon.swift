//
//  ApprovedReviewIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

import SwiftUI

struct ApprovedReviewIcon: View {
    var body: some View {
        Text("Approved")
            .font(.system(size: 11))
            .foregroundColor(.green)
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 1)
            )
    }
}

struct ApprovedReviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        ApprovedReviewIcon()
    }
}
