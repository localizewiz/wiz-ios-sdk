//
//  UrlRequestConvertible.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

protocol UrlRequestConvertible {
    func toUrlRequest() -> URLRequest
}
