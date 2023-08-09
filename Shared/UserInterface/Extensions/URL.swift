//
//  URL.swift
//  GitLab
//
//  Created by Stef Kors on 09/08/2023.
//

import Foundation

extension URL {
    // Should re-encode any non-escaped utf8 strings
    // TODO: check and use URL(string: String, encodingInvalidCharacters: Bool) for future macOS versions
    static func encodingfallback(string: String?, withAllowedCharactersInPercentEncodingFallback: CharacterSet) -> URL? {
        guard let string else { return nil }

        if let url = URL(string: string) {
            return url
        }

        if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encodedString)
        }

        return nil
    }
}
