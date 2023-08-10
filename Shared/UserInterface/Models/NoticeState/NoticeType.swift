//
//  File.swift
//  
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation
import Defaults

 enum NoticeType: String, Defaults.Serializable, CaseIterable, Codable {
    case information
    case warning
    case error
    case network
    case branch
}
