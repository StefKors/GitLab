//
//  InboxZeroIcon.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct InboxZeroIcon: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("All done 🥳")
                Spacer()
            }
            Spacer()
        }
        .frame(height: 180)
    }
}

struct InboxZeroIcon_Previews: PreviewProvider {
    static var previews: some View {
        InboxZeroIcon()
    }
}
