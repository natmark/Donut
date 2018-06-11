//
//  RemoveCommand.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/11.
//

import Foundation
import Commandant
import Result
import DonutKit
import Curry

public struct RemoveCommand: CommandProtocol {
    public typealias Options = RemoveOptions

    public let verb = "remove"
    public let function = "Remove Xcode file templates from File Templates"
    public func run(_ options: RemoveOptions) -> Result<(), DonutError> {
        let templates = TemplateDirectory.search(name: options.templateName)

        if options.forceYes && (templates.count == 1 || !options.safe) {
            _ = templates.map { removeTemplate(template: $0) }
            return .success(())
        }

        if templates.count > 1 {
            for (i, template) in templates.enumerated() {
                Swift.print("\(i + 1). \(template.formattedString())")
            }
            Swift.print("\(templates.count + 1). All templates")

            var input: Int = 0
            repeat {
                Swift.print(">", terminator: "")
                input = Int(readLine() ?? "") ?? 0
            } while !(input >= 1 && input <= templates.count + 1)

            if input == templates.count + 1 {
                _ = templates.map { removeTemplate(template: $0) }
            } else {
                return removeTemplate(template: templates[input - 1])
            }

        } else if let template = templates.first {
            Swift.print("Found templates:")
            Swift.print(template.formattedString(), terminator: "\n\n")

            var input = ""
            repeat {
                Swift.print("Continue with Uninstall? [yN]", terminator: "")
                input = readLine() ?? ""
            } while !(input == "y" || input == "N")

            if input == "y" {
                return removeTemplate(template: template)
            }
        }

        return .success(())
    }

    private func removeTemplate(template: Template) -> Result<(), DonutError> {
        let templateName = template.formattedString()

        if TemplateDirectory.directoryContents(path: template.path.deletingLastPathComponent(), handlingTemplate: true).count == 1,
            let remoteRepoURL = template.remoteRepoURL {

            guard let result = TemplateDirectory.removeDirectory(url: remoteRepoURL).first() else {
                return .failure(DonutError.internalError(description: "Something went wrong"))
            }

            if let error = result.error {
                return .failure(error)
            }
        } else {
            guard let result = TemplateDirectory.removeTemplate(template: template).first() else {
                return .failure(DonutError.internalError(description: "Something went wrong"))
            }

            if let error = result.error {
                return .failure(error)
            }
        }

        Swift.print("Successfully uninstalled \(templateName)")
        return .success(())
    }
}

public struct RemoveOptions: OptionsProtocol {
    let safe: Bool
    let forceYes: Bool
    let templateName: String

    public static func evaluate(_ m: CommandMode) -> Result<RemoveOptions, CommandantError<DonutError>> {
        return curry(self.init)
            <*> m <| Option(key: "safe", defaultValue: false, usage: "disable --force-yes if multi template files found")
            <*> m <| Option(key: "force-yes", defaultValue: false, usage: "No show dialog when remove template")
            <*> m <| Argument(usage: "template name")

    }
}
