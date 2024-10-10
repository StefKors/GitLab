//
//  TokenInformationView.swift
//  GitLab
//
//  Created by Stef Kors on 11/07/2023.
//

import SwiftUI

struct TokenInformationView: View {
    let token: AccessToken?

    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                Text("Name:")
                    .foregroundStyle(.secondary)
                Text("\(token?.name ?? "")")
            }

            GridRow {
                Text("Created at:")
                    .foregroundStyle(.secondary)
                Text("\(token?.createdAt ?? "")")
            }

            GridRow {
                Text("Last used at:")
                    .foregroundStyle(.secondary)
                Text("\(token?.lastUsedAt ?? "")")
            }

            GridRow {
                Text("Expires at:")
                    .foregroundStyle(.secondary)
                Text("\(token?.expiresAt ?? "")")
            }

            GridRow {
                Text("Revoked:")
                    .foregroundStyle(.secondary)
                HStack {
                    Text("\(token?.revoked?.description ?? "")")
                    if let revoked = token?.revoked {
                        if revoked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            GridRow {
                Text("Active:")
                    .foregroundStyle(.secondary)
                HStack {
                    Text("\(token?.active?.description ?? "")")
                    if let active = token?.active {
                        if active {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            GridRow {
                Text("Scopes:")
                    .foregroundStyle(.secondary)
                HStack {
                    if let scopes = token?.scopes {
                        ForEach(scopes, id: \.self) { scope in
                            GroupBox {
                                Text(scope)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TokenInformationView_Previews: PreviewProvider {
    static var previews: some View {
        TokenInformationView(token: .preview)
    }
}
