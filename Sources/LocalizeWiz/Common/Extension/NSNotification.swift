//
//  NSNotification.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-02-15.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

public extension NSNotification.Name {

    static let WizLanguageChanged: NSNotification.Name = Notification.Name("LocalizeWiz.LanguageChanged")
    static let WizProjectLoaded: Notification.Name = Notification.Name("LocalizeWiz.ProjectLoaded")
}
