//
//  WizError.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

public enum WizError: Error {
    
    case genericError(message: String)
    case networkError(body: [String: Any])
    case fileError
    case unknowkError
    case error(error: Error)

    var message: String {
        switch self {
        case .genericError(let message):
            return message
        case .networkError(let body):
            return body["message"] as? String ?? "Error"
        case .fileError:
            return "File does not exists"
        case .unknowkError:
            return "Unknown Error"
        case .error(let err):
            return err.localizedDescription
        }
    }

    var localizedDescription: String {
        return message
    }

    var body: [String: Any] {
        switch self {
        case .genericError(let message):
            return ["message": message]
        case .networkError(let body):
            return body
        case .fileError:
            return ["message": "File error"]
        case .unknowkError:
            return ["message": "Unknown Error"]
        case .error(let err):
            return ["message": err.localizedDescription]
        }
    }
}
