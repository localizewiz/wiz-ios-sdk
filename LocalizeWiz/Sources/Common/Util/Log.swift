//
//  Log.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class Log {

    private static let logPrefix: String = "LocalizeWiz"
    private static var dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    private static var currentLogLevel: LogLevel = .v

    static var dateFormatter: DateFormatter {
       let formatter = DateFormatter()
       formatter.dateFormat = dateFormat
       formatter.locale = Locale.current
       formatter.timeZone = TimeZone.current
       return formatter
     }


    enum LogLevel: Int {
        case s = 0      // severe
        case e          // error
        case w          // warn
        case i          // info
        case d          // debug
        case v          // verbose
    }

    static var logIndicators: [LogLevel: String] = [
        .e : "[‼️]",
        .w : "[⚠️]",
        .i : "[ℹ️]",
        .d : "[💬]",
        .v : "[🔬]",
        .s : "[🔥]"
    ]

    static func setLogLevel(_ logLevel: LogLevel) {
        self.currentLogLevel = logLevel
    }

    static func s(_ object: Any) {
        log(object, level: .s)
    }

    static func e(_ object: Any) {
        log(object, level: .e)
    }

    static func w(_ object: Any) {
        log(object, level: .w)
    }

    static func i(_ object: Any) {
        log(object, level: .i)
    }

    static func d(_ object: Any) {
        log(object, level: .d)
    }

    static func v(_ object: Any) {
        log(object, level: .v)
    }

    private static func log(_ object: Any, level: LogLevel) {
        if level.rawValue <= self.currentLogLevel.rawValue {
            print("\(Date().toString()) - [\(logPrefix)] - \(logIndicators[level]!) => \(String(describing: object))")
        }
    }
}
