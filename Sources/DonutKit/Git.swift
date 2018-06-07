//
//  Git.swift
//  DonutKit
//
//  Created by AtsuyaSato on 2018/06/08.
//

import Foundation
import ReactiveTask
import ReactiveSwift
import Result

// https://github.com/Carthage/Carthage/blob/192a61d37b6ad27ec5d20d0d267ea3e70917689a/Source/CarthageKit/Git.swift

public let donutRequiredGitVersion = "2.3.0"

/// Checks if the git version satisfies the given required version.
public func ensureGitVersion(_ requiredVersion: String = donutRequiredGitVersion) -> SignalProducer<Bool, DonutError> {
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

public func launchGitTask(
    _ arguments: [String],
    repositoryFileURL: URL? = nil,
    standardInput: SignalProducer<Data, NoError>? = nil,
    environment: [String: String]? = nil
    ) -> SignalProducer<String, DonutError> {
    // See https://github.com/Carthage/Carthage/issues/219.
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
