//
//  Project.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-29.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

/// Pure data model for a localization project.
/// String cache management and API calls live in Wiz (the actor).
public struct Project: Codable, Sendable {

    public var id: String
    public var name: String?
    public var description: String?
    public var languageId: String?
    public var platform: String?
    public var created: Date?
    public var updated: Date?
    public var iconUrl: String?
    public var workspaceId: String?
    public var workspace: Workspace?
    public var language: Language?
    public var languages: [Language]?
    public var isInitialized: Bool?

    init(withId id: String) {
        self.id = id
    }
}

extension Project: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{id: \(id), name: \(String(describing: name)), platform: \(String(describing: platform)), created: \(String(describing: created)), updated: \(String(describing: updated))}"
    }
}

extension Project: Cacheable {

    typealias T = Project

    static var cacheUrl: URL? {
        return FileUtils.wizCachesDirectoryUrl()?.appendingPathComponent("project")
    }

    func saveToCache() {
        guard let cacheUrl = Project.cacheUrl,
              let data = try? JSONEncoder.wizEncoder.encode(self) else { return }
        try? data.write(to: cacheUrl)
    }

    static func initFromCache() -> Project? {
        guard let cacheUrl = Project.cacheUrl,
              FileManager.default.fileExists(atPath: cacheUrl.path),
              let data = try? Data(contentsOf: cacheUrl) else { return nil }
        return try? JSONDecoder.wizDecoder.decode(Project.self, from: data)
    }
}
