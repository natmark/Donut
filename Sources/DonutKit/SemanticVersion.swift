//
//  SemanticVersion.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation

public struct SemanticVersion {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension SemanticVersion {
    public func toString() -> String {
        return [major, minor, patch].map { String($0) }.joined(separator: ".")
    }
}
