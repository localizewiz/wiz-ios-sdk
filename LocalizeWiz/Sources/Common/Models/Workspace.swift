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
    public var apiKey: String
    public var created: Date
    public var updated: Date
    public var activeUntil: Date
    public var numberOfProjects: Int?
    public var numberOfMembers: Int?
    public var projectLimit: Int
    public var stringLimit: Int
    public var languageLimit: Int
    public var planId: String
    public var projects: [Project]?
}

extension Workspace: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "{id: \(id), \(name), \(slug)}"
    }
}
