//
//  Template.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/07.
//

import Foundation

public struct Template {
    public let path: URL

    public init(path: URL) {
        self.path = path
    }
}

extension Template {
    public var remoteFileURL: URL? {
        return URL(string: "https://\(self.host)/\(self.user)/\(self.repository)/\(self.nameWithExtension)")
    }

    public var remoteRepoURL: URL? {
        return URL(string: "https://\(self.host)/\(self.user)/\(self.repository)")
    }

    public var name: String {
        return self.path
            .deletingPathExtension()
            .lastPathComponent // template (remove extension)
    }

    public var nameWithExtension: String {
        return self.path
            .lastPathComponent // template
    }

    public var repository: String {
        return self.path
            .deletingLastPathComponent() // template
            .lastPathComponent // repository
    }

    public var user: String {
        return self.path
            .deletingLastPathComponent() // template
            .deletingLastPathComponent() // repository
            .lastPathComponent // user
    }

    public var host: String {
        return self.path
            .deletingLastPathComponent() // template
            .deletingLastPathComponent() // repository
            .deletingLastPathComponent() // user
            .lastPathComponent // host
    }

    public var version: String {
        return Git.getGitTagFromLocalRepo(url: self.path) ?? "undefined"
    }

    public func formattedString(all: Bool = true, version: Bool = true) -> String {
        var result = ""
        if all {
            result = "\([self.host, self.user, self.repository, self.nameWithExtension].joined(separator: "/"))"
        } else {
            result = "\(self.nameWithExtension)"
        }

        if version {
            result += " (\(self.version))"
        }

        return result
    }
}

