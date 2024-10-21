//
//  BaseTextView.swift
//  
//
//  Created by Stef Kors on 26/07/2022.
//

import SwiftUI

struct BaseTextView: View {
    var message: String
    var body: some View {
        HStack(alignment: .center) {
            Text(message)
                .padding(.top, 3)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

struct BaseTextView_Previews: PreviewProvider {
    static var previews: some View {
        BaseTextView(message: "testing the message")
    }
}
