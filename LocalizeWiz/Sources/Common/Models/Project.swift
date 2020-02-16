//
//  Project.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-29.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

public class Project: Codable {

    public var id: String
    public var name: String
    public var description: String
    public var languageId: String
    public var platform: String
    public var created: Date
    public var updated: Date
    public var iconUrl: String?
    public var workspaceId: String?
    public var workspace: Workspace?
    public var language: Language?
    public var languages: [Language]?
    public var isInitialized: Bool?

    private lazy var localizations: StringsCaches = StringsCaches()

//    public var files: [Any]

    func initialize() {
        Log.i("Initializing project")
    }

    static func readFromCache() -> Project? {
        return nil
    }


    // MARK: Dealing with strings

    public func getString(_ key: String, inLanguage languageCode: String) -> String? {
        return localizations.getString(key, inLanguage: languageCode)
    }
    
    func saveStrings(_ strings: [LocalizedString], forLanguage languageCode: String) {
        self.localizations.saveLocalizedStrings(strings, forLanguage: languageCode)
    }
}

extension Project: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{id: \(id), name: \(name), platform: \(platform), created: \(created), updated: \(updated)}"
    }


}
