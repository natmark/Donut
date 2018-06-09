//
//  InstallCommand.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/08.
//

import Foundation
import Commandant
import Result
import DonutKit
import Curry

public struct InstallCommand: CommandProtocol {
    public typealias Options = InstallOptions
    public let verb = "install"
    public let function = "Install Xcode file templates from remote repo"

    public func run(_ options: InstallOptions) -> Result<(), DonutError> {
        guard let url = URL(string: options.urlString) else {
            return .failure(DonutError.urlDecodeError)
        }
        let version = options.version

        Git.installTemplateFrom(url: url, version: version).first()

        guard let result = Git.checkExistenceOfRemoteRepoWith(url: url, version: version).first() else {
            return .failure(DonutError.internalError(description: "Cannot access to Git remote repository"))
        }

        switch result {
        case .success(_): break
        case .failure(let error):
            print(error)
            return .failure(error)
        }

        return .success(())
    }
}

public struct InstallOptions: OptionsProtocol {
    let version: String
    let urlString: String

    public static func evaluate(_ m: CommandMode) -> Result<InstallOptions, CommandantError<DonutError>> {
        return curry(self.init)
                <*> m <| Option(key: "version", defaultValue: "latest", usage: "version of Xcode file templates (default latest)")
                <*> m <| Argument(usage: "remote repository's url")
    }
}
