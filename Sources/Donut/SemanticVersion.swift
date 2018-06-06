//
//  SemanticVersion.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation

public protocol VersionType: Hashable {}

/// A semantic version.
public struct SemanticVersion: VersionType {
    /// The major version.
    ///
    /// Increments to this component represent incompatible API changes.
    public let major: Int

    /// The minor version.
    ///
    /// Increments to this component represent backwards-compatible
    /// enhancements.
    public let minor: Int

    /// The patch version.
    ///
    /// Increments to this component represent backwards-compatible bug fixes.
    public let patch: Int

    /// A list of the version components, in order from most significant to
    /// least significant.
    public var components: [Int] {
        return [ major, minor, patch ]
    }

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public func toString() -> String {
        return [major, minor, patch].map { String($0) }.joined(separator: ".")
    }
}
