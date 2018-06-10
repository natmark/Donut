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

    public static func installTemplateFrom(url: URL, version: String) -> SignalProducer<Void, DonutError> {
        let dirPath = URL(fileURLWithPath: TemplateDirectory.baseURL.path + "/\(url.host!)\(url.path)")
        guard let commit = checkExistenceOfRemoteRepoWith(url: url, version: version).first()?.value else {
            return SignalProducer(error: DonutError.internalError(description: "Cannot access to Git remote repository"))
        }
        print("*Found \(url.absoluteString) (\(version))")

        return TemplateDirectory.removeDirectory(url: url)
            .attemptMap { _ in
                TemplateDirectory.makeDirectory(url: url)
                    .first()!
            }
            .attemptMap { _ in
                launchGitTask(["init"], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .attemptMap { _ in
                //TODO: Error if origin already exists
                launchGitTask(["remote", "add", "origin", url.absoluteString], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .attemptMap { _ in
                launchGitTask(["fetch", "origin", commit.id], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .attemptMap { _ in
                launchGitTask(["ls-tree", "--name-only", "-r", commit.id], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .flatMap(.latest) { input -> SignalProducer<[String], DonutError> in
                        let files = input.components(separatedBy: "\n").dropLast().filter { $0.hasSuffix(".xctemplate") }
                        if files.count == 0 {
                            return SignalProducer(error: DonutError.templateFileNotFoundError)
                        }
                        return SignalProducer(value: files)
                    }
                    .first()!
            }
            .attemptMap { files in
                launchGitTask(["checkout", commit.id, "--"] + files, repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .map { _ in
                Swift.print("*Checkout from \(url.absoluteString)")
            }
            .attemptMap { _ in
                launchGitTask(["checkout", "-b", commit.version], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .attemptMap { _ in
                launchGitTask(["commit", "-a", "-m", "\"set tag\""], repositoryFileURL: dirPath, standardInput: nil, environment: nil)
                    .first()!
            }
            .map { _ in
                Swift.print("Template completely installed")
            }
    }

    public static func checkExistenceOfRemoteRepoWith(url: URL, version: String) -> SignalProducer<Commit, DonutError> {
        return launchGitTask(["ls-remote", "-t", url.absoluteString])
            .flatMap(.latest) { input -> SignalProducer<Commit, DonutError> in
                let tags = input.components(separatedBy: "\n").dropLast().map { $0.components(separatedBy: "\t") }.map { Commit(id: $0[0], version: $0[1].replacingOccurrences(of: "refs/tags/", with: "")) }
                if version == "latest" && tags.count > 0 {
                    return SignalProducer(value: tags.last!)
                }

                for tag in tags where tag.version == version {
                    return SignalProducer(value: tag)
                }

                return SignalProducer(error: DonutError.tagNotFoundError)
            }
            .mapError { _ -> DonutError in
                return DonutError.repositoryNotFoundError
            }
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
