//
//  ListCommand.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/07.
//

import Foundation
import Commandant
import Result
import DonutKit
import Curry

public struct TemplateList {
    public static func show(all: Bool) {
        let templates = TemplateDirectory.templates
        for template in templates {
            if all {
                Swift.print(template.formattedString(all: true))
            } else {
                Swift.print(template.formattedString(all: false))
            }
        }
    }
}

public struct ListCommand: CommandProtocol {
    public typealias Options = ListOptions
    public let verb = "list"
    public let function = "Display the list of installed Xcode file templates"
    public func run(_ options: ListOptions) -> Result<(), DonutError> {
        TemplateList.show(all: options.all)
        return .success(())
    }
}

public struct ListOptions: OptionsProtocol {
    let all: Bool

    public static func evaluate(_ m: CommandMode) -> Result<ListOptions, CommandantError<DonutError>> {
        return curry(self.init)
            <*> m <| Option(key: "all", defaultValue: false, usage: "Show full address of templates")
    }
}
