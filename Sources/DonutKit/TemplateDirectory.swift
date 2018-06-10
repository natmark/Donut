//
//  TemplateDirectory.swift
//  Donut
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation
import ReactiveTask
import ReactiveSwift
import Result

public struct TemplateDirectory {
    public static let templatePathExtension = "xctemplate"
    public static var homeDirectory: URL = {
        let homeDirectory: URL
        if #available(OSX 10.12, *) {
            homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        } else {
            homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
        }
        return homeDirectory
    }()

    public static let baseURL: URL = {
        let XcodeFileTemplateDirectory = TemplateDirectory.homeDirectory
            .appendingPathComponent("Library")
            .appendingPathComponent("Developer")
            .appendingPathComponent("Xcode")
            .appendingPathComponent("Templates")
            .appendingPathComponent("File Templates")

        return XcodeFileTemplateDirectory
    }()

    public static let hostURLs: [URL] = {
        return TemplateDirectory.directoryContents(url: TemplateDirectory.baseURL)
    }()

    public static let userURLs: [URL] = {
        var users = [URL]()
        for host in TemplateDirectory.hostURLs {
            users += TemplateDirectory.directoryContents(url: host)
        }

        return users
    }()

    public static let repositoryURLs: [URL] = {
        var repos = [URL]()
        for user in TemplateDirectory.userURLs {
            repos += TemplateDirectory.directoryContents(url: user)
        }

        return repos
    }()

    public static let templateURLs: [URL] = {
        var templates = [URL]()
        for repository in TemplateDirectory.repositoryURLs {
            templates += TemplateDirectory.directoryContents(url: repository).filter {
                $0.pathExtension == TemplateDirectory.templatePathExtension
            }
        }

        return templates
    }()

    public static let templates: [Template] = {
        return TemplateDirectory.templateURLs.map { Template(path: $0) }
    }()

    public static func removeDirectory(url: URL) -> SignalProducer<String, DonutError> {
        let taskDescription = Task("/usr/bin/env", arguments: ["rm", "-rf", "\(url.host!)/\(url.path)"], workingDirectoryPath: TemplateDirectory.baseURL.path, environment: nil)
        return taskDescription.launch()
            .ignoreTaskData()
            .mapError(DonutError.taskError)
            .map { data in
                return String(data: data, encoding: .utf8)!
        }
    }

    public static func makeDirectory(url: URL) -> SignalProducer<String, DonutError> {
        let taskDescription = Task("/usr/bin/env", arguments: ["mkdir", "-p", "\(url.host!)/\(url.path)"], workingDirectoryPath: TemplateDirectory.baseURL.path, environment: nil)
        return taskDescription.launch()
            .ignoreTaskData()
            .mapError(DonutError.taskError)
            .map { data in
                return String(data: data, encoding: .utf8)!
        }
    }

    private static func directoryContents(url: URL) -> [URL] {
        guard let directoryContents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
            )
        else {
            return []
        }
        return directoryContents
    }
}
