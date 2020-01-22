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
    public var language: Language
    public var isoCode: String
    public var languageId: String
    public var flagUrl: String
    public var platform: String
    public var creationDate: Date
    public var iconName: String
    public var workspaceId: String
    public var numberOfStrings: String
    public var numberOfFiles: String
    public var numberOfLanguages: String
    public var workspace: Workspace?
    public var languages: [Language]
    public var state: String
    public var isSetUp: Bool?

    private lazy var localizations: StringsCaches = StringsCaches()

//    public var files: [Any]

    func setup() {

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
