//
//  OptionalType.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import Foundation

public protocol OptionalType: ExpressibleByNilLiteral {
    associatedtype WrappedType
    var asOptional: WrappedType? { get }
}

extension Optional: OptionalType {
    public var asOptional: Wrapped? {
        return self
    }
}
