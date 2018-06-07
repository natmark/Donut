//
//  Template.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/07.
//

import Foundation

public struct Template {
    let path: URL

    public init(path: URL) {
        self.path = path
    }
}

extension Template {
    public var name: String {
        get {
            return self.path
                .lastPathComponent // template
        }
    }

    public var repository: String {
        get {
            return self.path
                .deletingLastPathComponent() // template
                .lastPathComponent // repository
        }
    }

    public var user: String {
        get {
            return self.path
                .deletingLastPathComponent() // template
                .deletingLastPathComponent() // repository
                .lastPathComponent // user
        }
    }

    public var host: String {
        get {
            return self.path
                .deletingLastPathComponent() // template
                .deletingLastPathComponent() // repository
                .deletingLastPathComponent() // user
                .lastPathComponent // host
        }
    }
}
