//
//  File.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import SwiftUI
import SwiftData

struct NoticeListView: View {
    @Query private var notices: [NoticeMessage]

    var body: some View {
        if !notices.isEmpty {
            VStack {
                ForEach(notices.filter({ $0.dismissed == false }), id: \.id) { notice in
                    BaseNoticeItem(notice: notice)
                        .id(notice.id)
                }
            }
            .animation(.spring(), value: notices)
        }
    }
}
