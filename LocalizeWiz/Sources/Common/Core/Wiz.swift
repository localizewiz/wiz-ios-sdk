//
//  Wiz.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation

let wizQueue: DispatchQueue = DispatchQueue(label: "LocalizeWiz",
                                            qos: .default,
                                            attributes: [],
                                            autoreleaseFrequency: .inherit,
                                            target: nil)

public class Wiz {

    public private (set) static var sharedInstance: Wiz = Wiz()

    private init() {}

    public private (set) var project: Project?
    public private (set) var workspace: Workspace?

    internal private (set) var config: Config? = nil

    private lazy var api: WizApiService = WizApiService()
    private var currentLanguageCode = Locale.current.languageCode ?? ""

    public func configure(apiKey: String, projectId: String, language: String? = Locale.current.languageCode) {
        guard !apiKey.isEmpty else {
            Log.s("Invalid apiKey: \(apiKey)")
            return
        }
        guard !projectId.isEmpty else {
            Log.s("Invalid projectId: \(projectId)")
            return
        }

        self.config = Config(apiKey: apiKey, projectId: projectId)

        api.getProjectDetailsById(projectId) { (project, error) in

            if let project = project {
                self.project = project
                if let workspace = project.workspace {
                    self.workspace = workspace
                }

                if let isInitialized = project.isInitialized, !isInitialized {
                    project.initialize()
                }
            } else if let error = error {
                Log.e(error)
            }

            self.refresh()
        }
    }

    public func refresh() {
        let languageCode = self.currentLanguageCode

        if let project = self.project {
            api.getStringTranslations(project.id, fileId: nil, language: languageCode) { (strings, error) in
                if let strings = strings {
                    self.project?.saveStrings(strings, forLanguage: languageCode)
                }
            }
        }
    }

    public func fetchLocalizations(_ languages: [String]) {
        
    }

    public func setLanguage(_ languageCode: String) {
        if self.isValidLanguage(languageCode) {
            self.currentLanguageCode = languageCode
        }
        refresh()
    }

    public func isValidLanguage(_ languageCode: String) -> Bool {
        return true
    }

    // MARK:- Convenience methods

    public func getString(_ key: String) -> String {
        var string: String = self.project?.getString(key, inLanguage: self.currentLanguageCode) ?? ""

        // fallback
        if string.isEmpty {
            string = NSLocalizedString(key, comment: "")
        }
        return string
    }

    var isConfigured: Bool {
        return self.config != nil
    }

}

extension Wiz {

    private func restoreProjectFromCache() {

    }
}
