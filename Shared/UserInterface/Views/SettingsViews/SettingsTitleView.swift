//
//  SettingsTitleView.swift
//  GitLab
//
//  Created by Stef Kors on 08/11/2024.
//

import SwiftUI

struct SettingsTitleView: View {
    let label: String
    let systemImage: String
    let fill: Color

    private let radius: CGFloat = 8
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white)
                .imageScale(.small)
                .symbolRenderingMode(.hierarchical)
                .fontWeight(.bold)
                .frame(width: 26, height: 26, alignment: .center)
                .background {
                    LinearGradient(colors: [
                        fill.lighter(by: 20),
                        fill
                    ], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .shadow(color: Color.black.lighter(by: 10).opacity(0.7), radius: 2, y: 2)
                    .border(fill.darker(by: 10), width: 1, cornerRadius: radius)
                }
            //                .padding(.leading, 6)

            Text(label)
        }
        .font(.title2)
        .fontWeight(.semibold)
    }
}

#Preview {
    VStack(alignment: .center) {
        SettingsTitleView(label: "Account", systemImage: "person.2.fill", fill: .blue.darker(by: 15))
            .padding(.horizontal)
        SettingsTitleView(label: "Audio", systemImage: "slider.horizontal.3", fill: .pink)
            .padding(.horizontal)
        SettingsTitleView(label: "General", systemImage: "gearshape.fill", fill: .gray.darker(by: 15))
            .padding(.horizontal)
        SettingsTitleView(label: "Credentials", systemImage: "key.fill", fill: .black)
            .padding(.horizontal)
    }
    .scenePadding()
}
