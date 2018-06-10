//
//  DonutErrors.swift
//  Commandant
//
//  Created by AtsuyaSato on 2018/06/06.
//

import Foundation
import ReactiveTask

public enum DonutError: Error {
    case internalError(description: String)
    case taskError(TaskError)
    case urlDecodeError
    case repositoryNotFoundError
    case tagNotFoundError
    case directoryCreateError
    case gitError
    case templateFileNotFoundError
}
