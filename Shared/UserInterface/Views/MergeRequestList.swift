//
//  MergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 08/05/2024.
//

import SwiftUI

struct MergeRequestList: View {
    var mergeRequests: [UniversalMergeRequest]
    var accounts: [Account]
    var selectedView: QueryType

    private var accountByID: [Account.ID: Account] {
        Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) })
    }

    private var rowModels: [MergeRequestRowModel] {
        mergeRequests.map { request in
            MergeRequestRowModel(request: request, account: accountByID[request.accountsId])
        }
    }

    var body: some View {
        PlainMergeRequestList(rowModels: rowModels)
//        if accounts.count > 1 {
//            SectionedMergeRequestList(
//                accounts: accounts,
//                selectedView: selectedView
//            )
//        } else {
//            PlainMergeRequestList(mergeRequests: mergeRequests)
//        }
    }
}

#Preview {
    MergeRequestList(
        mergeRequests: [.preview, .preview2],
        accounts: [.preview],
        selectedView: .authoredMergeRequests
    )
}
