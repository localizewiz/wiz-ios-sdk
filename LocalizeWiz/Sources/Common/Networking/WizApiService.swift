//
//  WizApiService.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

let wizDecoder = JSONDecoder.wizDecoder

class WizApiService {

    private let networkService: NetworkService = NetworkService()

    init() {}

    func getProject(_ projectId: String, completion: @escaping(Result<Project, WizError>) -> Void) {
        let request = WizApiRequest.getProject(projectId: projectId)

        networkService.sendRequest(request) { (result) in
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

    func getProjectDetailsById(_ projectId: String, completion: @escaping(Result<Project, WizError>) -> Void) {
        let request = WizApiRequest.getProjectDetails(projectId: projectId)

        networkService.sendRequest(request) { (result) in
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

    func getStringTranslations(_ projectId: String, fileId: String?, language: String, completion: @escaping(Result<[LocalizedString], Error>) -> Void) {
        let request = WizApiRequest.getStringTranslations(projectId: projectId, fileId: fileId, locale: language)

        networkService.sendRequest(request) { (result) in
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

    func getProjectLanguages(_ projectId: String, completion: @escaping (Result<[Language], WizError>) -> Void) {
        let request = WizApiRequest.getProjectLanguages(projectId: projectId)

        networkService.sendRequest(request) { (result) in
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

    func uploadProjectFile(_ projectId: String, filename: String, fileData: Data, completion: @escaping (Bool, Error?) -> Void) {
        let request = WizApiRequest.uploadFile(projectId: projectId, fileName: filename, fileData: fileData, contentType: "text/plain")

        networkService.sendRequest(request) { (result) in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}
