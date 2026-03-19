//
//  WizApiService.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

let wizDecoder = JSONDecoder.wizDecoder

// Phase 2 will replace this with a Google Translate + local cache approach.
// @unchecked Sendable: owns only a NetworkService (itself @unchecked Sendable).
final class WizApiService: @unchecked Sendable {

    private let networkService = NetworkService()

    // Set by Wiz actor during setup() so requests carry the correct auth header.
    var apiKey: String = ""

    init() {}

    func getProject(_ projectId: String, completion: @escaping @Sendable (Result<Project, WizError>) -> Void) {
        send(.getProject(projectId: projectId)) { (result) in
            switch result {
            case .success(let data):
                if let data = data, let project = try? wizDecoder.decode(Project.self, from: data) {
                    completion(.success(project))
                } else {
                    completion(.failure(WizError.unknowkError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getProjectDetailsById(_ projectId: String, completion: @escaping @Sendable (Result<Project, WizError>) -> Void) {
        send(.getProjectDetails(projectId: projectId)) { (result) in
            switch result {
            case .success(let data):
                if let data = data, let project = try? wizDecoder.decode(Project.self, from: data) {
                    completion(.success(project))
                } else {
                    completion(.failure(WizError.unknowkError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getStringTranslations(_ projectId: String, fileId: String?, language: String, completion: @escaping @Sendable (Result<[LocalizedString], any Error>) -> Void) {
        send(.getStringTranslations(projectId: projectId, fileId: fileId, locale: language)) { (result) in
            switch result {
            case .success(let data):
                if let data = data, let envelope = try? wizDecoder.decode(LocalizedStringEnvelope.self, from: data) {
                    completion(.success(envelope.strings))
                } else {
                    completion(.failure(WizError.unknowkError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getProjectLanguages(_ projectId: String, completion: @escaping @Sendable (Result<[Language], WizError>) -> Void) {
        send(.getProjectLanguages(projectId: projectId)) { (result) in
            switch result {
            case .success(let data):
                if let data = data, let envelope = try? wizDecoder.decode(LanguageEnvelope.self, from: data) {
                    completion(.success(envelope.languages))
                } else {
                    completion(.failure(WizError.unknowkError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func uploadProjectFile(_ projectId: String, filename: String, fileData: Data, completion: @escaping @Sendable (Bool, (any Error)?) -> Void) {
        send(.uploadFile(projectId: projectId, fileName: filename, fileData: fileData, contentType: "text/plain")) { (result) in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }

    // Injects the auth header before handing the request to NetworkService.
    private func send(_ request: WizApiRequest, completion: @escaping CompletionWithResult) {
        var urlRequest = request.toUrlRequest()
        if !apiKey.isEmpty {
            urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        networkService.sendRequest(urlRequest, completion: completion)
    }
}
