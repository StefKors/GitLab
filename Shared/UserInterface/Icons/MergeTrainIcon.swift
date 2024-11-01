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
            .font(.system(size: 11, weight: .regular))
            .transition(
                .opacity
                    .combined(with: .scale(0, anchor: .leading)
                        .animation(.snappy.delay(0.1))
                        .combined(with: .blurReplace)
                    )
                    .animation(.snappy)
            )
            .foregroundStyle(.primary.opacity(0.8))
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.secondary)
                    .opacity(0.2)
            )
    }
}

struct MergeTrainIcon_Previews: PreviewProvider {
    static var previews: some View {
        MergeTrainIcon()
    }
}
