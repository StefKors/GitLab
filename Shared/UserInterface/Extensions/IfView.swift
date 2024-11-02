//
//  IfView.swift
//  GitLab
//
//  Created by Stef Kors on 02/11/2024.
//


extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
