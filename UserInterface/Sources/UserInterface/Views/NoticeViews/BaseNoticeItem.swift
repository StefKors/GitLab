//
//  BaseNoticeItem.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import SwiftUI

struct BaseNoticeItem: View {
    var notice: NoticeMessage
    var removeNotice: ((_ notice: NoticeMessage) -> Void)?
    @State var isHovering: Bool = false

    var styleColor: Color {
        switch notice.type {
        case .information, .network:
            return .blue
        case .warning:
            return .yellow
        case .error:
            return .red
        }

    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let statusCode = notice.statusCode {
                VStack(alignment: .center) {
                    ZStack {
                        HStack(alignment: .center) {
                            Image(systemName: "exclamationmark.icloud.fill")
                                .foregroundColor(styleColor)
                            // One bigger than the xmark icon to make sure background renders correctly
                                .font(.system(size: 19))
                                .help("Close")
                            Text("\(statusCode)")
                                .bold()
                        }
                        .foregroundColor(styleColor)
                    }
                }
                .padding()
                .background(styleColor.opacity(0.3))
            }
            VStack(alignment: .center) {
                ZStack {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(notice.label)
                                .lineLimit(1)
                                .font(.body)
                        }
                        Spacer()
                        if isHovering {
                            Text("close")
                                .transition(.opacity)
                                .transition(.move(edge: .trailing))
                        }
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .help("Close")
                            .onHover { hoverState in
                                isHovering = hoverState
                            }
                            .onTapGesture {
                                removeNotice?(notice)
                            }
                    }
                    .foregroundColor(styleColor)
                    .animation(.spring(), value: isHovering)
                }
            }
            .padding()
        }
        .background(styleColor.opacity(0.3))
        .background(.thickMaterial)
        .cornerRadius(4)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 4)
                .stroke(styleColor, lineWidth: 1)
        )
        .shadow(color: styleColor.opacity(0.35), radius: 5, x: 0, y: 3)
    }

}

struct BaseNoticeItem_Previews: PreviewProvider {
    static let informationNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: nil,
        type: .information
    )
    static let warningNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: 502,
        type: .warning
    )
    static let errorNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be",
        statusCode: 404,
        type: .error
    )

    static var previews: some View {
        VStack(spacing: 25) {
            BaseNoticeItem(notice: informationNotice)
            BaseNoticeItem(notice: warningNotice)
            BaseNoticeItem(notice: errorNotice)
        }.padding()
    }
}
