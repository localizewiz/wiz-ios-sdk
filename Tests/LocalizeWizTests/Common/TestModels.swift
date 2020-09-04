//
//  TestModels.swift
//  LocalizeWizTests
//
//  Created by John Warmann on 2020-01-22.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import XCTest
@testable import LocalizeWiz

class TestModels: XCTestCase {

    var reader: FileReader!
    var decoder: JSONDecoder!
    var encoder: JSONEncoder!
    var bundle: Bundle!

    override func setUp() {
        decoder = JSONDecoder.wizDecoder
        encoder = JSONEncoder()
        reader = FileReader()
        bundle = Bundle(for: type(of: self))
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateProject() {
        let data = reader.readFile(fileName: "Project", ofType: "json", in: bundle)!
        let project = try! decoder.decode(Project.self, from: data)
        XCTAssertNotNil(project)
    }

    func testCreateProjectWithDetails() {
        let data = reader.readFile(fileName: "ProjectWithDetails", ofType: "json", in: bundle)!
        let project = try! decoder.decode(Project.self, from: data)
        XCTAssertNotNil(project)
    }

    func testCreateWorkspace() {
        let data = reader.readFile(fileName: "Workspace", ofType: "json", in: bundle)!
        let workspace = try! decoder.decode(Workspace.self, from: data)
        XCTAssertNotNil(workspace)
    }

    func testCreateLanguage() {
        let data = reader.readFile(fileName: "Language", ofType: "json", in: bundle)!
        let language = try! decoder.decode(Language.self, from: data)
        XCTAssertNotNil(language)
    }

    func testLocalizedStringEnvelope() {
        let data = reader.readFile(fileName: "LocalizedStringEnvelope", ofType: "json", in: bundle)!
        let envelope = try! decoder.decode(LocalizedStringEnvelope.self, from: data)
        XCTAssertNotNil(envelope)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
