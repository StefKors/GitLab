//
//  Collection.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

extension BidirectionalCollection where Element == CollectionDifference<GitLab.Author>.Change {
    /// Return all elements of changed type `.insert`
    var insertedElements: [GitLab.Author] {
        return self.compactMap({ insertion -> GitLab.Author? in
            guard case let .insert(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }

    /// Return all elements of changed type `.remove`
    var removedElements: [GitLab.Author] {
        return self.compactMap({ insertion -> GitLab.Author? in
            guard case let .remove(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }
}

extension Sequence {
    func uniqueElements<T: Hashable>(byProperty propertyAccessor: (Element) -> T) -> [Element] {
        var seen: Set<T> = []
        var result: [Element] = []
        for element in self {
            let property = propertyAccessor(element)
            if !seen.contains(property) {
                result.append(element)
                seen.insert(property)
            }
        }
        return result
    }
}

extension Sequence where Element: Hashable {
    func uniqueElements() -> [Element] {
        return uniqueElements(byProperty: { $0 })
    }
}

extension Sequence {
    func uniqueElements(by elementsEqual: (Element, Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(where: { resultElement in elementsEqual(element, resultElement) }) {
                result.append(element)
            }
        }
        return result
    }
}

extension Sequence where Element: Equatable {
    func uniqueElements() -> [Element] {
        return uniqueElements(by: ==)
    }
}
