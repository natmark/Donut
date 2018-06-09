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

public struct Commit {
    public let id: String
    public let version: String
    init(id: String, version: String) {
        self.id = id
        self.version = version
    }
}

public struct Git {
    public static let donutRequiredGitVersion = "2.3.0"

    public static func installTemplateFrom(url: URL, version: String) -> SignalProducer<String, DonutError> {

        let makeDirectory = Task("/usr/bin/env", arguments: ["mkdir", "-p","\(url.host!)/\(url.path)"], workingDirectoryPath: TemplateDirectory.baseURL.path, environment: nil)

        let dirPath = TemplateDirectory.baseURL.path + "/\(url.host!)/\(url.path)"
        let gitInit = Task("/usr/bin/env", arguments: ["git", "init"], workingDirectoryPath: dirPath, environment: nil)

        let gitRemoteAdd = Task("/usr/bin/env", arguments: ["git", "remote", "add", "origin", url.absoluteString], workingDirectoryPath: dirPath, environment: nil)

        guard let result = checkExistenceOfRemoteRepoWith(url: url, version: version).first() else {
            return SignalProducer(error: DonutError.internalError(description: "Cannot access to Git remote repository"))
        }
        let commit: Commit
        switch result {
        case .success(let result):
            print("*Found \(url.absoluteString) (\(version))")
            commit = result
        case .failure(let error):
            return SignalProducer(error: error)
        }

        let gitFetch = Task("/usr/bin/env", arguments: ["git", "fetch", "origin", commit.id], workingDirectoryPath: dirPath, environment: nil)

        let gitCheckout = Task("/usr/bin/env", arguments: ["git", "checkout", commit.id, "--", "README.md"], workingDirectoryPath: dirPath, environment: nil)

        let gitCheckoutBranch = Task("/usr/bin/env", arguments: ["git", "checkout", "-b", commit.version], workingDirectoryPath: dirPath, environment: nil)

        let gitCommit = Task("/usr/bin/env", arguments: ["git", "commit", "-a", "-m", "\"set tag\""], workingDirectoryPath: dirPath, environment: nil)

        return makeDirectory.launch()
            .ignoreTaskData()
            .map { _ -> Result<Data, TaskError>? in
                return gitInit.launch()
                    .ignoreTaskData()
                    .first()
            }
            .map { _ -> Result<Data, TaskError>? in
                return gitRemoteAdd.launch()
                    .ignoreTaskData()
                    .first()
            }
            .map { _ -> Result<Data, TaskError>? in
                return gitFetch.launch()
                    .ignoreTaskData()
                    .first()
            }
            .map { _ -> Result<Data, TaskError>? in
                Swift.print("*Checkout from \(url.absoluteString)")
                return gitCheckout.launch()
                    .ignoreTaskData()
                    .first()
            }
            .map { _ -> Result<Data, TaskError>? in
                return gitCheckoutBranch.launch()
                    .ignoreTaskData()
                    .first()
            }
            .map { _ -> Result<Data, TaskError>? in
                return gitCommit.launch()
                    .ignoreTaskData()
                    .first()
            }
            .mapError(DonutError.taskError)
            .map { data -> String in
                switch data {
                case .success(let data)?:
                    return String(data: data, encoding: .utf8)!
                default: break
                }
                return ""
            }
    }

    public static func checkExistenceOfRemoteRepoWith(url: URL, version: String) -> SignalProducer<Commit, DonutError> {
        return launchGitTask(["ls-remote", "-t", url.absoluteString]).flatMap(.latest) { input -> SignalProducer<Commit, DonutError> in
            let tags = input.components(separatedBy: "\n").dropLast().map { $0.components(separatedBy: "\t") }.map { Commit(id: $0[0], version: $0[1].replacingOccurrences(of: "refs/tags/", with: "")) }
            if version == "latest" && tags.count > 0 {
                return SignalProducer(value: tags.last!)
            }

            for tag in tags {
                if tag.version == version {
                    return SignalProducer(value: tag)
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
