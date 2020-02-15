//
//  Language.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-29.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

public class Language: Codable {
    
    public var id: String
    public var isoCode: String
    public var englishName: String
    public var localName: String
    public var isChecked: Bool?
    public var flagUrl: URL?
    public var flagUrl2: URL?
    public var countryFlag: String?
    public var added: Date?
    public var updated: Date?
}
