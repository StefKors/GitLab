//
//  UserDefaultsFix.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import Defaults
import Foundation

// https://github.com/sindresorhus/Defaults/issues/93
// extension Defaults.Serializable where Self: Codable {
//     public static var bridge: Defaults.TopLevelCodableBridge<Self> { Defaults.TopLevelCodableBridge() }
// }
//
// extension Defaults.Serializable where Self: Codable & NSSecureCoding {
//     public static var bridge: Defaults.CodableNSSecureCodingBridge<Self> { Defaults.CodableNSSecureCodingBridge() }
// }
//
// extension Defaults.Serializable where Self: Codable & NSSecureCoding & Defaults.PreferNSSecureCoding {
//     public static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
// }
//
// extension Defaults.Serializable where Self: Codable & RawRepresentable {
//     public static var bridge: Defaults.RawRepresentableCodableBridge<Self> { Defaults.RawRepresentableCodableBridge() }
// }
//
// extension Defaults.Serializable where Self: Codable & RawRepresentable & Defaults.PreferRawRepresentable {
//     public static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
// }
//
// extension Defaults.Serializable where Self: RawRepresentable {
//     public static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
// }
// extension Defaults.Serializable where Self: NSSecureCoding {
//     public static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
// }
//
// extension Defaults.CollectionSerializable where Element: Defaults.Serializable {
//     public static var bridge: Defaults.CollectionBridge<Self> { Defaults.CollectionBridge() }
// }
//
// extension Defaults.SetAlgebraSerializable where Element: Defaults.Serializable & Hashable {
//     public static var bridge: Defaults.SetAlgebraBridge<Self> { Defaults.SetAlgebraBridge() }
// }
