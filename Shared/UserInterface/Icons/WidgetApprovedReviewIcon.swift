//
//  WidgetApprovedReviewIcon.swift
//  GitLab
//
//  Created by Stef Kors on 18/10/2024.
//

import SwiftUI

struct WidgetApprovedReviewIcon: View {
    @State private var isHovering: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Text(Image(systemName: "checkmark"))
                .help(String(localized: "Merge request approved"))
                .clipShape(Rectangle())

            if isHovering {
                Text("Approved")

                    .transition(
                        .opacity
                            .combined(with: .scale(0, anchor: .leading)
                                .animation(.snappy.delay(0.1))
                                .combined(with: .blurReplace)
                            )
                            .animation(.snappy)
                    )
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 7))
            }
        }
        .font(.footnote)
        .foregroundStyle(.green)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .opacity(0.2)
        )
        .onHover(perform: { state in
            withAnimation(.snappy) {
                isHovering = state
            }
        })
        .help(String(localized: "Merge request approved"))
    }
}

#Preview {
    VStack(alignment: .leading) {
        HStack {
            WidgetApprovedReviewIcon()
            Text("testing a preview")
        }
        HStack {
            WidgetApprovedReviewIcon()
            Text("another one test preview")
        }
        HStack {
            WidgetApprovedReviewIcon()
            Text("even more testing a preview")
        }
        HStack {
            WidgetApprovedReviewIcon()
            Text("testing a preview")
        }
    }
    .frame(width: 400, height: 200, alignment: .leading)
    .scenePadding()
}
