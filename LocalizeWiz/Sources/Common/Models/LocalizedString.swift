//
//  LocalizedString.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

public class LocalizedString: Codable {
    
    public var id: String?
    public var name: String
    public var value: String
    public var autoTranslation: String?
    public var humanTranslation: String?
    public var comments: String?
    public var metadata: [String: String]?
    public var translatable: Bool?
    public var locale: String?
    public var created: Date?
    public var updated: Date?
    public var translations: [String: String]?

    func getValue(forLanguage languageCode: String? = nil) -> String {
        guard languageCode != nil else {
            return value
        }

        // check valid language
        if let languageCode = languageCode, let translation = translations?[languageCode] {
            return translation
        }
        return value
    }
}

extension LocalizedString: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "id=\(String(describing: id)), name=\(name), value=\(value), autoTranslation=\(String(describing: autoTranslation)), humanTranslation = \(String(describing: humanTranslation))"
    }
}
