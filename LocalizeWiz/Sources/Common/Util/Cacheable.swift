//
//  Cacheable.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-02-16.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

protocol Cacheable {
    associatedtype T

    static var cacheUrl: URL? { get }
    static func initFromCache() -> T?

    func saveToCache()
}
