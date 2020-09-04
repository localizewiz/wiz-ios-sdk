//
//  Cache.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class Cache: Codable {

    private var _cache: [String: LocalizedString] = [:]

    func set(_ value: LocalizedString, forKey key: String) {
        _cache[key] = value
    }

    func get(_ key: String) -> LocalizedString? {
        return _cache[key]
    }

    func clear() {
        _cache.removeAll()
    }
}

extension Cache: CustomDebugStringConvertible {

    public var debugDescription: String {
        return _cache.map { (k, v) -> String in
            "\(k) => \(v)"
        }.joined(separator: "\n")
    }
}
