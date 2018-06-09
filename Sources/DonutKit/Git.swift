//
//  Git.swift
//  DonutKit
//
//  Created by AtsuyaSato on 2018/06/08.
//
// https://github.com/Carthage/Carthage/blob/192a61d37b6ad27ec5d20d0d267ea3e70917689a/Source/CarthageKit/Git.swift

import Foundation
import ReactiveTask
import ReactiveSwift
import Result

public struct Git {
    public static let donutRequiredGitVersion = "2.3.0"

    public static func checkExistenceOfRemoteRepoWithVesrion(_ url: URL, version: String) -> SignalProducer<Void, DonutError> {
        return launchGitTask(["ls-remote", "-t", url.absoluteString]).flatMap(.latest) { input -> SignalProducer<Void, DonutError> in
            let tags = input.components(separatedBy: "\n").dropLast().map { $0.components(separatedBy: "\t") }.map { (commit: $0[0], version: $0[1].replacingOccurrences(of: "refs/tags/", with: "")) }

            if version == "latest" && tags.count > 0 {
                return SignalProducer(value: ())
            }

            for tag in tags {
                if tag.version == version {
                    return SignalProducer(value: ())
                }
            }
            return SignalProducer(error: DonutError.tagNotFoundError)
        }.mapError { error -> DonutError in
            return DonutError.repositoryNotFoundError
        }

    }

    public static func installTemplateFrom(_ url: URL, version: String) -> SignalProducer<Bool, DonutError> {
        return launchGitTask(["--version"]).map { input -> Bool in return true} // TODO: remove
    }

    /// Checks if the git version satisfies the given required version.
    public static func ensureGitVersion(_ requiredVersion: String = Git.donutRequiredGitVersion) -> SignalProducer<Bool, DonutError> {
        return launchGitTask([ "--version" ])
            .map { input -> Bool in
                let scanner = Scanner(string: input)
                guard scanner.scanString("git version ", into: nil) else {
                    return false
                }

                var version: NSString?
                if scanner.scanUpTo("", into: &version), let version = version {
                    return version.compare(requiredVersion, options: [ .numeric ]) != .orderedAscending
                } else {
                    return false
                }
        }
    }

    public static func launchGitTask(
        _ arguments: [String],
        repositoryFileURL: URL? = nil,
        standardInput: SignalProducer<Data, NoError>? = nil,
        environment: [String: String]? = nil
        ) -> SignalProducer<String, DonutError> {

        var updatedEnvironment = environment ?? ProcessInfo.processInfo.environment
        updatedEnvironment["GIT_TERMINAL_PROMPT"] = "0"

        let taskDescription = Task("/usr/bin/env", arguments: [ "git" ] + arguments, workingDirectoryPath: repositoryFileURL?.path, environment: updatedEnvironment)

        return taskDescription.launch(standardInput: standardInput)
            .ignoreTaskData()
            .mapError(DonutError.taskError)
            .map { data in
                return String(data: data, encoding: .utf8)!
        }
    }
}
