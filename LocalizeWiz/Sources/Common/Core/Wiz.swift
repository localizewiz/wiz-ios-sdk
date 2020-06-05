//
//  Wiz.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation



public class Wiz {

    public static let sharedInstance: Wiz = Wiz()


    private lazy var wizQueue: DispatchQueue = DispatchQueue(label: "LocalizeWiz",
                                                        qos: .default,
                                                        attributes: [],
                                                        autoreleaseFrequency: .inherit,
                                                        target: nil)
    private lazy var mainQueue = DispatchQueue.main

    public private (set) var project: Project?
    public private (set) var workspace: Workspace?

    internal private (set) var config: Config? = nil

    private lazy var api: WizApiService = WizApiService()
    private var currentLanguageCode = Locale.current.languageCode ?? ""
    private var globalLanguageChangeHandler: (() -> Void)? = nil


    private init() {}

    public func setup(apiKey: String, projectId: String, language: String? = Locale.preferredLanguages.first, localizationFileNames: [String] = ["Localizable.strings"]) {

        Log.d("User language is: \(String(describing: language))")

        guard !apiKey.isEmpty else {
            Log.s("Invalid apiKey: \(apiKey)")
            return
        }
        guard !projectId.isEmpty else {
            Log.s("Invalid projectId: \(projectId)")
            return
        }

        let language = language ?? self.currentLanguageCode
        self.currentLanguageCode = self.mappedLanguage(language)
        self.setupCaches()
        
        Log.d("Configuring project {apiKey: \(apiKey), projectId: \(projectId), language: \(String(describing: language))}")
        self.config = Config(apiKey: apiKey, projectId: projectId)

        self.restoreFromCache()

        api.getProjectDetailsById(projectId) { result in

            switch result {
            case .success(let project):
                self.wizQueue.async {
                    self.project = project
                    if let workspace = project.workspace {
                        self.workspace = workspace
                    }

                    if let isInitialized = project.isInitialized, !isInitialized {
                        project.initialize(withFilenames: localizationFileNames)
                    }

                    self.refresh()
                    self.saveCurrentProject()
                }
            case .failure(let error):
                Log.e(error)
            }
        }
    }

    public func refresh() {
        let languageCode = self.currentLanguageCode

        self.refreshLanguage(languageCode)
    }

    public func refreshLanguage(_ languageCode: String) {
        if let project = self.project {
            api.getStringTranslations(project.id, fileId: nil, language: languageCode) { result in
                switch result {
                case .success(let strings):
                    self.project?.saveStrings(strings, forLanguage: languageCode)
                    self.mainQueue.async {
                        self.notifyOfLanguageChange(languageCode)
                    }
                case .failure(let error):
                    Log.e(error)
                }
            }
        }
    }

    public func setLanguage(_ languageCode: String, completion handler: (Bool) -> Void) {
        self.currentLanguageCode = languageCode
        refresh()
    }

    public func setLanguageChangeHandler(_ handler: @escaping () -> Void) {
        self.globalLanguageChangeHandler = handler
    }

    // MARK:- Convenience methods

    public func getString(_ key: String) -> String {
        return self.getString(key, languageCode: self.currentLanguageCode)
    }

    public func getString(_ key: String, languageCode: String) -> String {
        var string: String = self.project?.getString(key, inLanguage: languageCode) ?? ""

        // fallback
        if string.isEmpty {
            string = NSLocalizedString(key, comment: "")
        }

        return string
    }

    var isConfigured: Bool {
        return self.config != nil
    }

    private func notifyOfLanguageChange(_ languageCode: String) {
        self.globalLanguageChangeHandler?()
        NotificationCenter.default.post(name: .WizLanguageChanged, object: nil, userInfo: ["languageCode":languageCode])
    }

    private func mappedLanguage(_ languageCode: String) -> String {
        let mapper = LanguageMapper()
        return mapper.mapLanguage(languageCode)
    }
}

// MARK: - Caching
extension Wiz {

    private func setupCaches() {
        FileUtils.createWizCachesDirectory()
    }

    private func saveCurrentProject() {
        if let project = self.project {
            project.saveToCache()
        }
    }

    private func restoreFromCache() {
        if let project = Project.initFromCache(), project.id == self.config?.projectId {
            self.project = project
            project.restoreFromCache()
        } else {
            self.project = nil
        }
    }
}
