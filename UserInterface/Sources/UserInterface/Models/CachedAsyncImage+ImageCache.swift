//
//  File.swift
//  
//
//  Created by Stef Kors on 17/09/2022.
//

import Foundation

// URLCache+imageCache.swift
extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
