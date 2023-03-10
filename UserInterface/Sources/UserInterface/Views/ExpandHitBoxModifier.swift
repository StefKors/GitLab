//
//  ExpandHitBoxModifier.swift
//  
//
//  Created by Stef Kors on 10/03/2023.
//

import SwiftUI

public struct ExpandHitBoxModifier: ViewModifier {
    let amount: CGFloat
    public func body(content: Content) -> some View {
        content
            .contentShape(.interaction, Rectangle().inset(by: -amount), eoFill: .init())
    }
}

extension View {
    /// Used to expand the hitbox of buttons larger than their shape size
    /// - Parameter amount: Amount to expand
    public func expandHitBox(_ amount: CGFloat) -> some View {
        return self.modifier(ExpandHitBoxModifier(amount: amount))
    }
}

struct ExpandHitBoxModifier_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            // action
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
        }
        .font(.system(size: 11))
        .buttonStyle(.menubar)
        .expandHitBox(20)
    }
}
