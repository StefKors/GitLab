//
//  ProgressIcon.swift
//  ProgressIcon
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct ProgressIcon: View {
    private let animation = Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
    @State var isAtMaxScale = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2.0)
                .opacity(0.3)
                .foregroundColor(.accentColor)
            
            
            Circle()
                .trim(from: 0.0, to: .pi/10)
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }.frame(width: 16, height: 16)
            .rotationEffect(Angle(degrees: self.isAtMaxScale ? 360.0 : 0.0))
            .onAppear {
                withAnimation(self.animation, {
                    self.isAtMaxScale.toggle()
                })
            }
    }
}

struct ProgressIcon_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIcon()
    }
}
