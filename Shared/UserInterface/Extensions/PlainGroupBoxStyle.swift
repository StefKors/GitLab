//
//  PlainGroupBoxStyle.swift
//  GitLab
//
//  Created by Stef Kors on 08/11/2024.
//

import SwiftUI

struct PlainGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .foregroundStyle(.secondary)

            configuration.content
                .background {
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                    .fill(.quinary)
                    .stroke(.quaternary, lineWidth: 1)
                }
        }
    }
}
