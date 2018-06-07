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

public struct TemplateList {
    public static func show() {
        let templates = TemplateDirectory.templates
        for template in templates {
            Swift.print([template.host, template.user, template.repository, template.name].joined(separator: "/"))
        }
    }
}

public struct ListCommand: CommandProtocol {
    public let verb = "list"
    public let function = "Display the list of installed xcode file templates"
    public func run(_ options: NoOptions<DonutError>) -> Result<(), DonutError> {
        TemplateList.show()
        return .success(())
    }
}

