//
//  UserDefaultsStorage.swift
//  GitLab
//
//  Created by Stef Kors on 21/10/2021.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let apiToken = Key<String>("apiToken", default: "")
}
