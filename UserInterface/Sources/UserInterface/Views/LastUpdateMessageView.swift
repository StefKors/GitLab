//
//  LastUpdateMessageView.swift
//  
//
//  Created by Stef Kors on 26/07/2022.
//

import SwiftUI

struct LastUpdateMessageView: View {
    @EnvironmentObject var model: NetworkManager

    public let initialTimeRemaining = 10
    @State public var isHovering: Bool = false
    @State public var timeRemaining = 10
    public let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public var dateValue: String? {
        guard let date = model.lastUpdate else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    var body: some View {
        HStack {
            Spacer()

            if let lastUpdate = dateValue {
                Text("Last updated at: \(lastUpdate)")
                    .transition(.opacity.animation(.easeInOut(duration: 0.35).delay(0.2)))
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }

                        if timeRemaining <= 0 {
                            timeRemaining = initialTimeRemaining
                            Task(priority: .background) {
                                await model.fetch()
                            }
                        }
                    }
            } else {
                LastUpdateMessagePlaceholderView()
            }
        }
        .padding(.bottom)
        .padding(.trailing)
    }
}

struct LastUpdateMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LastUpdateMessageView()
    }
}
