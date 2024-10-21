//
//  ShadedButton.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI


struct ShadedButtonStyle: ButtonStyle {
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.leading, 4)
            .padding(.vertical, 2)
            .padding(.trailing, 4)
            .background(.quaternary.opacity(opacity(isHovering, configuration.isPressed)), in: RoundedRectangle(cornerRadius: 6))
            .animation(.smooth(duration: 0.1), value: isHovering)
            .animation(.smooth(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovering = hovering
            }
    }

    func opacity(_ isHovering: Bool, _ isPressed: Bool) -> CGFloat {
            if isPressed {
                return 0.5
            } else if isHovering {
                return 0 // 0.5
            } else {
                return 0
            }
    }
}

extension ButtonStyle where Self == ShadedButtonStyle {
    static var shaded: Self { ShadedButtonStyle() }
}

#Preview {
    Button {
        // action
    } label: {
        HStack {
            Image(systemName: "square.and.arrow.up")
            Text("Share")
        }
    }
    .font(.system(size: 11))
    .buttonStyle(.shaded)
}
