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
            .foregroundStyle(Color.accentColor)
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .opacity(0.3)
            )

    }
}

//struct NeedsReviewIcon_Previews: PreviewProvider {
//    static var previews: some View {
//        NeedsReviewIcon()
//            .padding()
//    }
//}

struct NeedsReviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack {

            HStack(spacing: 2) {
                Image(systemName: "bird").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                Text(12.description)


            }
            .font(.largeTitle)


                Text("Needs Review")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .padding(EdgeInsets(top: 4, leading:    10, bottom: 4, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentColor)
                            .opacity(0.3)
                    )

        }
            .padding()
    }
}

