//
//  Storage.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

public class Storage {

    fileprivate init() { }

    enum Directory {
        case documents
        case caches
    }

    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL? {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }

        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            return nil
        }
    }


    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        if let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false) {

            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(object)
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            } catch {
                ErrorReporter.report(error)
            }
        }
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false) else {
            return nil
        }

        guard FileManager.default.fileExists(atPath: url.path)  else {
            return nil
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                ErrorReporter.report(error)
            }
        }
        return nil
    }

    /// Remove all files at specified directory
    static func clear(_ directory: Directory) {

        if let url = getURL(for: directory),
            let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
            for fileUrl in contents {
                try? FileManager.default.removeItem(at: fileUrl)
            }
        }
    }

    /// Remove specified file from specified directory
    static func remove(_ fileName: String, from directory: Directory) {
        if let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false) {
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }

    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        if let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false) {
            return FileManager.default.fileExists(atPath: url.path)
        }
        return false
    }
}
