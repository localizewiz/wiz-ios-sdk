//
//  WizApiService.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class WizApiService {

    private let networkService: NetworkService = NetworkService()

    let sharedInstance: WizApiService = WizApiService()

    init() {}

    func getProject(_ projectId: String, completion: @escaping(Project?, WizError?) -> Void) {
        let request = WizApiRequest.getProject(projectId: projectId)

        networkService.sendRequest(request) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = result as? Data, let response = try? JSONDecoder().decode(Project.self, from: data) {
                    completion(response, nil)
                } else {
                    completion(nil, WizError.unknowkError)
                }
            }
        }
    }

    func getProjectDetailsById(_ projectId: String, completion: @escaping(Project?, WizError?) -> Void) {
        let request = WizApiRequest.getProjectDetails(projectId: projectId)

        networkService.sendRequest(request) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = result as? Data, let response = try? JSONDecoder().decode(Project.self, from: data) {
                    completion(response, nil)
                } else {
                    completion(nil, WizError.unknowkError)
                }
            }
        }
    }

    func getStringTranslations(_ projectId: String, fileId: String?, language: String, completion: @escaping([LocalizedString]?, Error?) -> Void) {
        let request = WizApiRequest.getStringTranslations(projectId: projectId, fileId: fileId, locale: language)

        networkService.sendRequest(request) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = result as? Data, let envelope = try? JSONDecoder().decode(LocalizedStringEnvelope.self, from: data) {
                    completion(envelope.strings, nil)
                } else {
                    completion(nil, WizError.unknowkError)
                }
            }
        }
    }
}
