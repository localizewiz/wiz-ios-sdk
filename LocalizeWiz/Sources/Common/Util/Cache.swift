//
//  Cache.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class Cache {

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
