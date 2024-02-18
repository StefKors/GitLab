//
//  File.swift
//  
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation

 enum NoticeType: String, CaseIterable, Codable {
    case information
    case warning
    case error
    case network
    case branch
}
