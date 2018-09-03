//
//  VersionCommand.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation
import Commandant
import Result
import DonutKit

public struct DonutVersion {
    public let value: SemanticVersion
    public static let current = DonutVersion(value: SemanticVersion(major: 0, minor: 1, patch: 1))
}

public struct VersionCommand: CommandProtocol {
    public let verb = "version"
    public let function = "Display the current version of Donut"
    public func run(_ options: NoOptions<DonutError>) -> Result<(), DonutError> {
        Swift.print("🍩", "Donut version \(DonutVersion.current.value.toString())")
        return .success(())
    }
}
