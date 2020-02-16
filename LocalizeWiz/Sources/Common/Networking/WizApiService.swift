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

    func getProject(_ projectId: String, completion: @escaping(Project?, WizError?) -> Void) {
        let request = WizApiRequest.getProject(projectId: projectId)

        networkService.sendRequest(request) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = result as? Data, let response = try? wizDecoder.decode(Project.self, from: data) {
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
                if let data = result as? Data, let response = try? wizDecoder.decode(Project.self, from: data) {
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
                let json = try! JSONSerialization.jsonObject(with: result as! Data, options: .allowFragments)
                Log.d("Json: \(json)")
                let env = try! wizDecoder.decode(LocalizedStringEnvelope.self, from: result as! Data)
                Log.d("env: \(env)")
                if let data = result as? Data, let envelope = try? wizDecoder.decode(LocalizedStringEnvelope.self, from: data) {
                    completion(envelope.strings, nil)
                } else {
                    completion(nil, WizError.unknowkError)
                }
            }
        }
    }

    func getProjectLanguages(_ projectId: String, completion: @escaping ([Language]?, Error?) -> Void) {
        let request = WizApiRequest.getProjectLanguages(projectId: projectId)

        networkService.sendRequest(request) { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let json = try! JSONSerialization.jsonObject(with: result as! Data, options: .allowFragments)
                Log.d("Json: \(json)")
                let env = try! wizDecoder.decode(LanguageEnvelope.self, from: result as! Data)
                Log.d("env: \(env)")
                if let data = result as? Data, let envelope = try? wizDecoder.decode(LanguageEnvelope.self, from: data) {
                    completion(envelope.languages, nil)
                } else {
                    completion(nil, WizError.unknowkError)
                }
            }
        }
    }
}
