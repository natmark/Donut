//
//  TemplateDirectory.swift
//  Donut
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation

public struct TemplateDirectory {
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

    public static let hosts: [URL] = {
        let directoryContents = try? FileManager.default.contentsOfDirectory(
            at: TemplateDirectory.baseURL,
            includingPropertiesForKeys: nil,
            options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
        )

        guard let contents = directoryContents else {
            return []
        }

        return contents
    }()
}
