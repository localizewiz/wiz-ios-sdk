//
//  DateFormatter.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-22.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let wizFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
}
