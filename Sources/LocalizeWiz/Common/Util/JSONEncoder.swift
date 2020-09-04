//
//  JSONEncoder.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-23.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

extension JSONEncoder {
    static let wizEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.wizFormatter)
        return encoder
    }()
}
