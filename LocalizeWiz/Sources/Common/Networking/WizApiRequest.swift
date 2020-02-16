//
//  WizApiRequest.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
    case PATCH
    case PUT
    case OPTIONS
    case HEAD
}

enum WizApiRequest {

    case getProject(projectId: String)
    case getProjectDetails(projectId: String)

    case addString(projectId: String)
    case getStrings(projectId: String, fileId: String?)
    case getStringTranslations(projectId: String, fileId: String?, locale: String)
    case getProjectLanguages(projectId: String)

    case uploadFile(projectId: String, fileName: String, fileData: Data, contentType: String)

    private var multipartBoundary: String {
        return "XXX"
    }

    var baseUrl: URL {
        let testurl = "https://ecf825d3.ngrok.io"
        let realurl = "https://dev.api.localizewiz.com"
        return URL(string: testurl )!
    }

    var headers: [String: String] {
        guard let config = Wiz.sharedInstance.config else { return [:] }
        return ["x-api-key": config.apiKey]
    }

    var url: URL {
        switch self {
        case .getProject(let projectId):
            return baseUrl.appendingPathComponent("/projects/\(projectId)")
        case .getProjectDetails(let projectId):
            return baseUrl.appendingPathComponent("/projects/\(projectId)/details")
        case .addString(let projectId), .getStrings(let projectId, _):
            return baseUrl.appendingPathComponent("/projects/\(projectId)/strings")
        case .getProjectLanguages(let projectId):
            return baseUrl.appendingPathComponent("/projects/\(projectId)/languages")

        case .uploadFile(let projectId, _, _, _):
            return baseUrl.appendingPathComponent("/projects/\(projectId)/files")
        case .getStringTranslations(let projectId, _, let locale):
            return baseUrl.appendingPathComponent("/projects/\(projectId)/strings/translations/\(locale)")
        }
    }

    var method: HTTPMethod {
        switch self {
        case .addString, .uploadFile:
            return .POST
        default:
            return .GET
        }
    }

    var body: Data? {
        switch self {
        case .uploadFile(_, let fileName, let fileData, let contentType):
            let multipartData = self.multipartFormData(data: fileData,
                                                       boundary: self.multipartBoundary,
                                                       fileName: fileName,
                                                       contentType: contentType)
            return multipartData
        default:
            return nil
        }
    }

    var queryParameters: [String: String] {
        switch self {
        case .getStrings(_, let fileId), .getStringTranslations(_, let fileId, _):
            if let fileId = fileId {
                return ["file": fileId]
            }
        default:
            break
        }
        return [:]
    }

    var contentType: String {
        switch self {
        case .uploadFile:
            return "multipart/form-data; boundary=\(multipartBoundary)"
        default:
            return "application/json"
        }
    }

    private func multipartFormData(data: Data, boundary: String, fileName: String, contentType: String) -> Data {
        var fullData = Data()

        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 3
        let lineThree = "Content-Type: \(contentType)\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 4
        fullData.append(data as Data)

        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        return fullData
    }
}

extension WizApiRequest: UrlRequestConvertible {

    func toUrlRequest() -> URLRequest {
        let url = self.url

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if !self.queryParameters.isEmpty {
            urlComponents!.queryItems = [URLQueryItem]()
            for (key, value) in queryParameters {
                let queryItem = URLQueryItem(name: key, value: value)
                urlComponents?.queryItems?.append(queryItem)
            }
            let escapedComponents = urlComponents?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            urlComponents?.percentEncodedQuery = escapedComponents
        }

        let request = NSMutableURLRequest(url: urlComponents!.url!)
        request.httpMethod = self.method.rawValue
        if request.allHTTPHeaderFields == nil {
            request.allHTTPHeaderFields = [:]
        }
        let headers = request.allHTTPHeaderFields?.merging(self.headers, uniquingKeysWith: { (first, _) -> String in
            first
        })
        request.allHTTPHeaderFields = headers

        if let httpBody = self.body {
            request.httpBody = httpBody
            request.addValue(self.contentType, forHTTPHeaderField: "Content-Type")
        }

        return request as URLRequest
    }
}
