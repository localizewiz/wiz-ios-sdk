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

        if let cacheUrlForLanguage = self.cacheUrl(forLanguage: languageCode) {
            let data = try? JSONEncoder.wizEncoder.encode(cache)
            try? data?.write(to: cacheUrlForLanguage)
        }
    }

    func restoreLocalizedStrings(forLangauge languageCode: String) {
        if let cacheUrlForLanguage = self.cacheUrl(forLanguage: languageCode),
            let data = try? Data(contentsOf: cacheUrlForLanguage),
            let cache = try? JSONDecoder.wizDecoder.decode(Cache.self, from: data) {
            caches[languageCode] = cache
        }
    }

    func cache(forLanguage languageCode: String)  -> Cache? {
        return caches[languageCode]
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

    func cacheUrl(forLanguage languageCode: String) -> URL? {
        if let url = FileUtils.wizCachesDirectoryUrl()?.appendingPathComponent("StringCaches-\(languageCode)") {
            return url
        }
        return nil
    }
}
