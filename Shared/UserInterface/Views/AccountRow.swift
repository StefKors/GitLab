//
//  AccountRow.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI

struct AccountRow: View {
    let account: Account
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let url = URL(string: account.instance), let host = url.host() {
                    Text(host)
                } else {
                    Text(account.instance)
                }

                Text(account.createdAt, style: .relative)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            Text(String(repeating: "⏺", count: 18))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AccountRow(account: .preview)
        .scenePadding()
}
