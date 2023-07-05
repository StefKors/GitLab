//
//  MergeTrainIcon.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct MergeTrainIcon: View {
    var body: some View {
        Text("Merge Train 🚂")
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.secondary, lineWidth: 2)
                    .opacity(0.3)
            )
    }
}

struct MergeTrainIcon_Previews: PreviewProvider {
    static var previews: some View {
        MergeTrainIcon()
    }
}
