//
//  PluralWidgetTitle.swift
//  GitLab
//
//  Created by Stef Kors on 18/10/2024.
//

import SwiftUI

struct PluralWidgetTitle: View {
    let count: Int
    var body: some View {
        Text("^[\(count) reviews](inflect: true) requested")
    }
}

#Preview {
    VStack {
        PluralWidgetTitle(count: 1)
        PluralWidgetTitle(count: 2)
    }
    .scenePadding()
}
