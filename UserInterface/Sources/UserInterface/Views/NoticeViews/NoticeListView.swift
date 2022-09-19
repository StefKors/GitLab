//
//  File.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import SwiftUI


struct NoticeListView: View {
    @EnvironmentObject public var noticeState: NoticeState

    var body: some View {
        VStack {
            ForEach(noticeState.notices.filter({ $0.dismissed == false }), id: \.id) { notice in
                BaseNoticeItem(notice: notice)
                    .id(notice.id)
            }
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: noticeState.notices)
    }
}
