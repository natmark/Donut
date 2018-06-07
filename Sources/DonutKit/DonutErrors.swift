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
}
