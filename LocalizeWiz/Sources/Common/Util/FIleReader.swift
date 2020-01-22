//
//  FIleReader.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-02.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class FileReader {

    func readFile(fileName: String, ofType fileType: String, in bundle: Bundle = Bundle.main) -> Data? {
        if let path = bundle.path(forResource: fileName, ofType: fileType) {
            let url = URL(fileURLWithPath: path)
            let data = try? Data(contentsOf: url)
            return data
        }

        return nil
    }
}
