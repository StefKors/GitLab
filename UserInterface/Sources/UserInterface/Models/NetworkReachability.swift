//
//  NetworkReachability.swift
//  
//
//  Created by Stef Kors on 26/07/2022.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import Foundation
#endif

func reachable(host: String) -> Bool {
    var res: UnsafeMutablePointer<addrinfo>?
    let n = getaddrinfo(host, nil, nil, &res)
    freeaddrinfo(res)
    return n == 0
}
