//
//  ProgressIcon.swift
//  ProgressIcon
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct CIProgressIcon: View {
    private let animation = Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
    @State private var isAtMaxScale = false
    @State private var firstLaunch = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2.0)
                .opacity(0.3)
                .foregroundStyle(Color.accentColor)

            Circle()
                .trim(from: 0.0, to: .pi/10)
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.accentColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: self.animation)
        }
        .frame(width: 16, height: 16)
        .rotationEffect(Angle(degrees: self.isAtMaxScale ? 360.0 : 0.0))
        .task(id: "once") {
            // avoid animation from triggering itself again
            if firstLaunch {
                self.firstLaunch = false
                withAnimation(self.animation, {
                    self.isAtMaxScale.toggle()
                })
            }
        }
        .padding(1)
        .help(String(localized: "CI in progress"))
        .clipShape(Rectangle())
    }
}

struct CIProgressIcon_Previews: PreviewProvider {
    static var previews: some View {
        CIProgressIcon()
    }
}
