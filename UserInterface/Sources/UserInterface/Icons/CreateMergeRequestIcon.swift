//
//  CreateMergeRequestIcon.swift
//  
//
//  Created by Stef Kors on 28/11/2022.
//

import SwiftUI
import TextToEmoji

struct CreateMergeRequestIcon: View {
    let MR: MergeRequest

    var body: some View {
        Button {
            copyToPasteboard()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
        }
        .buttonStyle(.plain)
        .font(.system(size: 11))
        .foregroundColor(.secondary)
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.secondary, lineWidth: 2)
                .opacity(0.3)
        )
    }

    func randomEmoji() -> String {
        return MR.title?.components(separatedBy: .whitespacesAndNewlines).map({ str in
            return str.asPointer.asEmoji
        }).randomElement() ?? "✨"
    }

    func copyToPasteboard() {
        let content = """
\(MR.title ?? "") \(randomEmoji())
\(MR.webURL?.absoluteString ?? "")
"""

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        NSPasteboard.general.setString(content, forType: .rtf)
    }
}

extension NSObject {
    fileprivate var asPointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
}


fileprivate let contiguousEmoji: [UnicodeScalar] = {
    let ranges: [ClosedRange<Int>] = [
        0x1f600...0x1f64f,
        0x1f680...0x1f6c5,
        0x1f6cb...0x1f6d2,
        0x1f6e0...0x1f6e5,
        0x1f6f3...0x1f6fa,
        0x1f7e0...0x1f7eb,
        0x1f90d...0x1f93a,
        0x1f93c...0x1f945,
        0x1f947...0x1f971,
        0x1f973...0x1f976,
        0x1f97a...0x1f9a2,
        0x1f9a5...0x1f9aa,
        0x1f9ae...0x1f9ca,
        0x1f9cd...0x1f9ff,
        0x1fa70...0x1fa73,
        0x1fa78...0x1fa7a,
        0x1fa80...0x1fa82,
        0x1fa90...0x1fa95,
    ]

    return ranges.reduce([], +).map { return UnicodeScalar($0)! }
}()


extension UnsafeMutableRawPointer {
    fileprivate var asEmoji: String {
        // Inspired by https://gist.github.com/iandundas/59303ab6fd443b5eec39
        let index = abs(self.hashValue) % contiguousEmoji.count
        return String(contiguousEmoji[index])
    }
}
