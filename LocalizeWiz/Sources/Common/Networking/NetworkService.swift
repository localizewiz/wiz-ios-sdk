//
//  NetworkService.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2019-12-31.
//  Copyright © 2019 LocalizeWiz. All rights reserved.
//

import Foundation


typealias NetworkCompletionHandler = (_ response: Any?, _ error: WizError?) -> Void

class NetworkService: NSObject {

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()

    func sendRequest(_ request: UrlRequestConvertible, completion: @escaping NetworkCompletionHandler) -> Void {

        let urlRequest = request.toUrlRequest()
//        if let authorization = AuthorizationRepository.shared.currentAuthorization {
//            urlRequest.setValue("Bearer \(authorization.token)", forHTTPHeaderField: "Authorization")
//        }
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            var serializedResponse: Any? = nil
            if let data = data {
                serializedResponse = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            }

            if let error = error {
                if let json = serializedResponse as? Json {
                   let appError = WizError.networkError(body: json)
                    return completion(nil, appError)
                } else {
                    let appError = WizError.genericError(message: error.localizedDescription)
                    return completion(nil, appError)
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let json = serializedResponse as? Json, let errorJson = json["error"] as? Json {
                    let appError = WizError.networkError(body: errorJson)
                    completion(nil, appError)
                } else {
                    completion(nil, WizError.unknowkError)
                }
                return
            }

            completion(data, nil)
        }
        task.resume()
    }
}
