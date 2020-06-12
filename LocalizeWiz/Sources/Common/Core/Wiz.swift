//
//  Wiz.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation


/// Entrypoint to Wiz SDK.
///
/// Use `Wiz.sharedInstance` to access commonly used methods and properties.
///
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
    private var currentLanguageCode = Locale.preferredLanguages.first ?? ""
    private var globalLanguageChangeHandler: (() -> Void)? = nil
    private var currentBundle: Bundle? = nil

    private let notifier = Notifier()
    private var observers = NSHashTable<AnyObject>(options: .weakMemory)

    private init() {}

    /// Setup the SDK.
    ///
    /// - Parameters:
    ///     - apiKey: Required.  Your API key. If you do not already have one, get one at https://app.localizewiz.com
    ///     - projectId: Id for your project
    ///     - languageCode: The default language code. Once set `getString()` returns strings in this language.
    ///     if the `languageCode` parameter is not set, the devices first preferred language is used.
    ///
    public func setup(apiKey: String, projectId: String, languageCode: String? = Locale.preferredLanguages.first, localizationFileNames: [String] = ["Localizable.strings"]) {

        Log.d("User language is: \(String(describing: languageCode))")

        guard !apiKey.isEmpty else {
            Log.s("Invalid apiKey: \(apiKey)")
            return
        }
        guard !projectId.isEmpty else {
            Log.s("Invalid projectId: \(projectId)")
            return
        }

        self.currentBundle = Bundle.main

        let language = languageCode ?? self.currentLanguageCode
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

    /// Refresh localizations
    ///
    /// Fetch the string translations for the current language
    ///
    public func refresh() {
        let languageCode = self.currentLanguageCode

        self.fetchStrings(languageCode: languageCode)
    }

    /// Fetch strings for given language
    ///
    /// - Parameters:
    ///     - languageCode: The `ISO-639-1` language to fetch strings for.
    ///
    public func fetchStrings(languageCode: String) {
        if let project = self.project {
            api.getStringTranslations(project.id, fileId: nil, language: languageCode) { result in
                switch result {
                case .success(let strings):
                    self.project?.saveStrings(strings, forLanguage: languageCode)
                    self.notifyOfLanguageChange(languageCode)
                case .failure(let error):
                    Log.e(error)
                }
            }
        }
    }

    public func setLanguage(_ languageCode: String) {
        self.currentLanguageCode = languageCode
        self.changeBundle(languageCode)
        refresh()
    }

    public func setLanguageChangeHandler(_ handler: @escaping () -> Void) {
        self.globalLanguageChangeHandler = handler
    }

    // MARK:- Convenience methods

    /// Get localized string for key
    ///
    /// Retrieves the localized string from the project.
    /// - Parameters:
    ///     - key: The
    /// - Returns: The string returned is the localizaed variant of string in the device's current preferred language.
    /// If a string for the key is not found in the project, this method looks up the key using `NSLocalizedString(key)` and returns the localized string if found.
    /// If a the string is not found using `NSLocalizedString`, the `key` requested is returned.
    ///
    public func getString(_ key: String) -> String {
        return self.getString(key, languageCode: self.currentLanguageCode)
    }

    /// Gets string in a given language
    ///
    /// - Returns: String localized in the specified language if available. If localization is not available, the key passed in is returned.
    /// - Precondition: `wiz.fetchStrings(languageCode)` must be called before `getString(languageCode)` is called.
    ///
    public func getString(_ key: String, languageCode: String) -> String {
        var string: String = self.project?.getString(key, inLanguage: languageCode) ?? ""

        // fallback
        if string.isEmpty {
            self.currentBundle?.localizedString(forKey: key, value: nil, table: nil)
        }
        if string.isEmpty, self.currentBundle != Bundle.main {
            string = NSLocalizedString(key, comment: "")
        }

        return string
    }

    private var isConfigured: Bool {
        return self.config != nil
    }

    private func notifyOfLanguageChange(_ languageCode: String) {
        self.mainQueue.async {
            self.globalLanguageChangeHandler?()
            self.notify(ofEvent: .languageChanged(languageCode: languageCode))
        }
    }

    private func mappedLanguage(_ languageCode: String) -> String {
        let mapper = LanguageMapper()
        return mapper.mapLanguage(languageCode)
    }

    private func changeBundle(_ languageCode: String) {
        if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"), let bundle = Bundle(path: bundlePath) {
            self.currentBundle = bundle
        }
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
        } else if let projectId = self.config?.projectId {
            self.project = Project(withId: projectId)
        } else {
            self.project = nil
        }
    }
}

extension Wiz {

    public func registerChangeObserver(_ observer: WizLocalizationChangeObzerver) {
        return self.notifier.addObserver(observer)
    }

    public func unregisterChangeOhangeObserver(_ observer: WizLocalizationChangeObzerver) {
        self.notifier.removeObserver(observer)
    }

    func notify(ofEvent event: WizEvent) {
        self.notifier.notifyObservers(ofEvent: event)
    }
}

public enum WizEvent {
    case languageChanged(languageCode: String)
    case stringsFetched(languageCode: String, strings: [LocalizedString])
}

public protocol WizLocalizationChangeObzerver: class {
    func handleEvent(_ event: WizEvent)
}
