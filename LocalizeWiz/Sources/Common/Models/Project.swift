//
//  Project.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-29.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

/// Manage Project operations
///
public class Project: Codable {

    public var id: String
    public var name: String?
    public var description: String?
    public var languageId: String?
    public var platform: String?
    public var created: Date?
    public var updated: Date?
    public var iconUrl: String?
    public var workspaceId: String?
    public var workspace: Workspace?
    public var language: Language?
    public var languages: [Language]?
    public var isInitialized: Bool?

    private lazy var localizations: StringsCaches = StringsCaches.instance
    private lazy var api: WizApiService = WizApiService()

//    public var files: [Any]

    func initialize(withFilenames filenames: [String]) {
        self.uploadProjectFiles(filenames)
        Log.i("Initializing project")
    }

    init(withId id: String) {
        self.id = id
    }

    static func readFromCache() -> Project? {
        return nil
    }


    // MARK: Dealing with strings

    /// Get string translation from project
    ///
    /// Gets the localized string for specified `key`.  If `key` does not exist in wiz project, this method does not fall back to use `NSLocalizedString()`.
    /// To have the fallback behavior, use `wiz.getString(key)` instead.
    ///
    ///  - Parameters:
    ///     - key: the Key to get
    ///     - languageCode: iso639-1 language code for localization to fetch.
    ///
    /// - Precondition: If the `languageCode` is the project's current language code, the localizations would already be cached on the device.
    /// To fetch localizations for another language, `wiz.fetchStrings(languageCode)` must be called first to fetch the localizations.
    ///
    public func getString(_ key: String, inLanguage languageCode: String) -> String? {
        return localizations.getString(key, inLanguage: languageCode)
    }
    
    func saveStrings(_ strings: [LocalizedString], forLanguage languageCode: String) {
        self.localizations.saveLocalizedStrings(strings, forLanguage: languageCode)
    }

    func restoreFromCache() {
        if let languages = self.languages {
            for language in languages {
                self.localizations.restoreLocalizedStrings(forLangauge: language.isoCode)
            }
        }
    }

    func cache(forLanguage languageCode: String) -> Cache? {
        return self.localizations.cache(forLanguage: languageCode)
    }

}

extension Project: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{id: \(id), name: \(String(describing: name)), platform: \(String(describing: platform)), created: \(String(describing: created)), updated: \(String(describing: updated))}"
    }
}

extension Project: Cacheable {

    typealias T = Project

    static var cacheUrl: URL? {
        let url = FileUtils.wizCachesDirectoryUrl()?.appendingPathComponent("project")
        return url
    }

    func saveToCache() {
        if let cacheUrl = Project.cacheUrl {
            let data = try! JSONEncoder.wizEncoder.encode(self)
            try! data.write(to: cacheUrl)
        }
    }

    static func initFromCache() -> Project? {
        if let cacheUrl = Project.cacheUrl,
            FileManager.default.fileExists(atPath: cacheUrl.path),
            let data = try? Data(contentsOf: cacheUrl) {
            return try? JSONDecoder.wizDecoder.decode(Project.self, from: data)
        }
        return nil
    }
}

extension Project {
    func uploadProjectFiles(_ filenames: [String]) {
        filenames.forEach { (filename) in
            self.uploadFile(filename)
        }

        Log.i("Initializing project")
    }

    func uploadFile(_ filename: String, inBundle bundle: Bundle = Bundle.main) {
        let dotIndex = filename.lastIndex(of: ".") ?? filename.endIndex
        let name = filename[..<dotIndex]
        let ext = filename[dotIndex...]
        if let resourceFilePath = bundle.path(forResource: String(name), ofType: String(ext)),
            let fileData = try? Data(contentsOf: URL(fileURLWithPath: resourceFilePath)) {
            api.uploadProjectFile(self.id, filename: filename, fileData: fileData) { (uploaded, error) in

            }
        }
    }
}
