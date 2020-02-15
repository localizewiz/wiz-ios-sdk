//
//  StringsCaches.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-04.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class StringsCaches {

    private var caches: [String: Cache] = [:]

    func getString(_ key: String, inLanguage languageCode: String) -> String? {
        if let cache = caches[languageCode] {
            return cache.get(key)?.humanTranslation
        }

        return nil
    }

    func saveLocalizedStrings(_ strings: [LocalizedString], forLanguage languageCode: String) -> Void {
        let cache = Cache()
        for string in strings {
            cache.set(string, forKey: string.name)
        }
        caches[languageCode] = cache
    }

    func purgeAll() {
        for (_, cache) in caches {
            cache.clear()
        }
        caches.removeAll()
    }

    func purge(_ languageCode: String) {
        if let cache = caches[languageCode] {
            cache.clear()
            caches.removeValue(forKey: languageCode)
        }
    }
}
