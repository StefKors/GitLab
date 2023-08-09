//
//  KeyedDecodingContainer.swift
//  GitLab
//
//  Created by Stef Kors on 09/08/2023.
//

import Foundation

extension KeyedDecodingContainer {
    // Should re-encode any non-escaped utf8 strings
    func decodeURLWithEncodingIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> URL? {
        let avatarString = try? self.decodeIfPresent(String.self, forKey: key)
        if let url = URL.encodingfallback(string: avatarString, withAllowedCharactersInPercentEncodingFallback: .urlQueryAllowed) {
            return url
        }

        let avatarURL = try? self.decodeIfPresent(URL.self, forKey: key)
        return avatarURL
    }
}
