//
//  NotificationButton.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct NotificationButton: View {
    var body: some View {
        Button(action: {

        }, label: {
            Text("show notification")
        })
    }
}

struct NotificationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationButton()
    }
}
