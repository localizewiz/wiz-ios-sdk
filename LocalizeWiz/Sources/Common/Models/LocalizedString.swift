//
//  LocalizedString.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class LocalizedString: Codable {
    
    var id: String?
    var key: String
    var value: String
    var machineTranslation: String?
    var humanTranslation: String?
    var comments: String?
    var metadata: [String: String]?
    var translatable: Bool
    var locale: String
    var created: Date?
    var updated: Date?
    var translations: [String: String]

    func getValue(forLanguage languageCode: String? = nil) -> String {
        guard languageCode != nil else {
            return value
        }

        // check valid language
        if let languageCode = languageCode, let translation = translations[languageCode] {
            return translation
        }
        return value
    }
}
