//
//  File.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import SwiftUI


struct NoticeListView: View {
    @EnvironmentObject  var noticeState: NoticeState
    
    var body: some View {
        if !noticeState.notices.isEmpty {
            VStack {
                ForEach(noticeState.notices.filter({ $0.dismissed == false }), id: \.id) { notice in
                    BaseNoticeItem(notice: notice)
                        .id(notice.id)
                }
            }
            .animation(.spring(), value: noticeState.notices)
        }
    }
}
