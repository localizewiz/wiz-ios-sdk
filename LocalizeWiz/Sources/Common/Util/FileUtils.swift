//
//  FileUtils.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class FileUtils {

    static func documentsDirectoryUrl() -> URL? {
        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return URL(fileURLWithPath: dir, isDirectory: true)
        }
        return nil
    }

    static func cachesDirectoryUrl() -> URL? {
        if let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return URL(fileURLWithPath: dir, isDirectory: true)
        }
        return nil
    }

    static func wizCachesDirectoryUrl() -> URL? {
        if let cachesDirectory = self.cachesDirectoryUrl() {
            let wizCacheDirectoryUrl = cachesDirectory.appendingPathComponent("localizewiz", isDirectory: true)
            return wizCacheDirectoryUrl
        }
        return nil
    }

    static func clearCache() {
        if let wizCachesDirectoryUrl = self.wizCachesDirectoryUrl() {
            try? FileManager.default.removeItem(at: wizCachesDirectoryUrl)
        }
    }
}
