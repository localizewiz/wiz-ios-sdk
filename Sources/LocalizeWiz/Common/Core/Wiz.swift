//
//  Wiz.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation


/// Entrypoint to the Wiz SDK.
///
/// Use `Wiz.shared` to access commonly used methods and properties.
/// All methods are actor-isolated — callers outside the actor must `await`.
///
public actor Wiz {

    // `static let` on an actor is safe: actors are always `Sendable`,
    // and a `let` binding is immutable shared state.
    public static let shared: Wiz = Wiz()

    // Backward-compatibility alias. Prefer `Wiz.shared`.
    public static var sharedInstance: Wiz { shared }

    // --- State (all actor-isolated: compiler-verified thread safety) ---

    public private(set) var project: Project?
    public private(set) var workspace: Workspace?
    internal private(set) var config: Config? = nil

    private let api = WizApiService()
    private let caches = StringsCaches.instance

    private var currentLanguageCode: String = Locale.preferredLanguages.first ?? "en"
    private var globalLanguageChangeHandler: (@Sendable () -> Void)? = nil
    private var currentBundle: Bundle? = nil

    // Weak observer storage keyed by ObjectIdentifier so we don't retain observers.
    private var observers: [ObjectIdentifier: WeakObserver] = [:]

    // Synchronous string snapshot for UIKit lookups.
    //
    // nonisolated(unsafe): the actor writes this after each successful fetch,
    // and UIKit reads it synchronously on the main thread via getString(forKey:).
    // A momentarily stale read is acceptable — worst case the UI shows the
    // previously fetched translation until the next refresh completes.
    nonisolated(unsafe) private var _snapshot: [String: String] = [:]

    private init() {}

    // MARK: - Setup

    /// Configure the SDK.
    ///
    /// - Parameters:
    ///   - apiKey: Your API key.
    ///   - projectId: Your project ID.
    ///   - languageCode: Initial language (defaults to device preferred language).
    ///   - localizationFileNames: Bundled `.strings` files to seed strings from.
    ///
    public func setup(apiKey: String, projectId: String, languageCode: String? = nil, localizationFileNames: [String] = ["Localizable.strings"]) {

        guard !apiKey.isEmpty else { Log.s("Invalid apiKey"); return }
        guard !projectId.isEmpty else { Log.s("Invalid projectId"); return }

        self.currentBundle = Bundle.main
        let language = languageCode ?? self.currentLanguageCode
        self.currentLanguageCode = self.mappedLanguage(language)
        self.config = Config(apiKey: apiKey, projectId: projectId)
        self.api.apiKey = apiKey  // Inject key so requests carry auth header

        Log.d("Configuring {apiKey: \(apiKey), projectId: \(projectId), language: \(language)}")

        // Restore cached project first so strings are available immediately,
        // then kick off a network refresh in the background.
        Task {
            await self.setupCaches()
            await self.restoreFromCache()

            do {
                let project = try await self.fetchProjectDetails(projectId)
                self.project = project
                if let ws = project.workspace { self.workspace = ws }
                await self.refresh()
                self.project?.saveToCache()
            } catch {
                Log.e(error)
            }
        }
    }

    // MARK: - Language

    public func setLanguage(_ languageCode: String) {
        self.currentLanguageCode = languageCode
        self.changeBundle(languageCode)
        Task { await self.refresh() }
    }

    /// Register a closure to be called (on the MainActor) when the language changes.
    public func setLanguageChangeHandler(_ handler: @escaping @Sendable () -> Void) {
        self.globalLanguageChangeHandler = handler
    }

    // MARK: - String retrieval

    // MARK: - String retrieval

    /// Synchronous string lookup for UIKit — safe to call from any context.
    ///
    /// Reads from `_snapshot`, which the actor updates after each successful fetch.
    /// A stale read is acceptable for UI: the view will refresh on the next
    /// language-change notification. This avoids the Swift 6.2 region-isolation
    /// issue of awaiting an actor method from a @MainActor Task.
    public nonisolated func getString(forKey key: String) -> String {
        return _snapshot[key] ?? NSLocalizedString(key, comment: "")
    }

    /// Async string lookup — use this from non-UIKit async contexts.
    public func getString(_ key: String) async -> String {
        return await self.getString(key, languageCode: self.currentLanguageCode)
    }

    /// Async string lookup in a specific language.
    public func getString(_ key: String, languageCode: String) async -> String {
        var string = await caches.getString(key, inLanguage: languageCode) ?? ""

        if string.isEmpty {
            string = self.currentBundle?.localizedString(forKey: key, value: nil, table: nil) ?? ""
        }
        if string.isEmpty, self.currentBundle != Bundle.main {
            string = NSLocalizedString(key, comment: "")
        }
        return string
    }

    // MARK: - Refresh

    /// Re-fetch strings for the current language from the API.
    public func refresh() async {
        await self.fetchStrings(languageCode: self.currentLanguageCode)
    }

    /// Fetch strings for a specific language from the API.
    public func fetchStrings(languageCode: String) async {
        guard let project = self.project else { return }
        do {
            let strings = try await self.fetchStringTranslations(project.id, language: languageCode)
            await caches.saveLocalizedStrings(strings, forLanguage: languageCode)
            // Update the synchronous snapshot so UIKit can read strings without awaiting.
            _snapshot = Dictionary(uniqueKeysWithValues: strings.compactMap { s -> (String, String)? in
                guard let value = s.humanTranslation ?? (s.value.isEmpty ? nil : s.value) else { return nil }
                return (s.name, value)
            })
            await notifyOfLanguageChange(languageCode)
        } catch {
            Log.e(error)
        }
    }

    // MARK: - Observers

    public func registerChangeObserver(_ observer: any WizLocalizationChangeObzerver) {
        let id = ObjectIdentifier(observer)
        observers[id] = WeakObserver(observer)
    }

    public func unregisterChangeObserver(_ observer: any WizLocalizationChangeObzerver) {
        observers.removeValue(forKey: ObjectIdentifier(observer))
    }

    // Kept for source compatibility (original had a typo in the method name).
    public func unregisterChangeOhangeObserver(_ observer: any WizLocalizationChangeObzerver) {
        unregisterChangeObserver(observer)
    }

    // MARK: - Private helpers

    private func setupCaches() async {
        FileUtils.createWizCachesDirectory()
    }

    private func restoreFromCache() async {
        if let cached = Project.initFromCache(), cached.id == self.config?.projectId {
            self.project = cached
            if let languages = cached.languages {
                for language in languages {
                    await caches.restoreLocalizedStrings(forLanguage: language.isoCode)
                }
            }
        } else if let projectId = self.config?.projectId {
            self.project = Project(withId: projectId)
        } else {
            self.project = nil
        }
    }

    private func notifyOfLanguageChange(_ languageCode: String) async {
        let handler = self.globalLanguageChangeHandler
        let event = WizEvent.languageChanged(languageCode: languageCode)

        await MainActor.run {
            handler?()
        }
        await notifyObservers(ofEvent: event)
    }

    private func notifyObservers(ofEvent event: WizEvent) async {
        // Prune dead references while iterating.
        var dead: [ObjectIdentifier] = []
        for (id, weak) in observers {
            if let observer = weak.value {
                await MainActor.run { observer.handleEvent(event) }
            } else {
                dead.append(id)
            }
        }
        dead.forEach { observers.removeValue(forKey: $0) }
    }

    private func mappedLanguage(_ languageCode: String) -> String {
        return LanguageMapper().mapLanguage(languageCode)
    }

    private func changeBundle(_ languageCode: String) {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.currentBundle = bundle
        }
    }

    // MARK: - Network bridges (completion handlers → async/await)
    //
    // withCheckedThrowingContinuation wraps the old completion-handler API
    // so it can be called with `await` like any other async function.
    // Phase 2 will replace these with direct Google Translate calls.

    private func fetchProjectDetails(_ projectId: String) async throws -> Project {
        return try await withCheckedThrowingContinuation { continuation in
            api.getProjectDetailsById(projectId) { result in
                switch result {
                case .success(let project): continuation.resume(returning: project)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchStringTranslations(_ projectId: String, language: String) async throws -> [LocalizedString] {
        return try await withCheckedThrowingContinuation { continuation in
            api.getStringTranslations(projectId, fileId: nil, language: language) { result in
                switch result {
                case .success(let strings): continuation.resume(returning: strings)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Supporting types

/// Box for a weak observer reference so the actor doesn't retain observers.
private final class WeakObserver: @unchecked Sendable {
    weak var value: (any WizLocalizationChangeObzerver)?
    init(_ value: any WizLocalizationChangeObzerver) { self.value = value }
}

// MARK: - Public types

public enum WizEvent: Sendable {
    case languageChanged(languageCode: String)
    case stringsFetched(languageCode: String, strings: [LocalizedString])
}

public protocol WizLocalizationChangeObzerver: AnyObject {
    @MainActor func handleEvent(_ event: WizEvent)
}
