//
//  Observable.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-06-10.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

protocol Observable: class {

    associatedtype Observer

    func addObserver(_ observer: Observer)

    func removeObserver(_ observer: Observer)
}
