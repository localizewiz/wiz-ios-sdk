//
//  Workspace.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-29.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

public class Workspace: Codable {

    public var id: String
    public var name: String
    public var slug: String
    public var ownerId: String
    public var created: Date
    public var updated: Date
    public var apiKey: String
    public var numberOfProjects: String
    public var numberOfMembers: String
    public var StringLimit: String
    public var languageLimit: String
    public var planId: String
    public var activeUntil: Date
    public var projects: [Project]
}
