//
//  JSONDecoder.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-22.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

extension JSONDecoder {

    static let wizDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.wizFormatter)
        return decoder
    }()
}
