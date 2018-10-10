//
//  ContactTests.swift
//  UnitTests
//
//  Created by Peter Fong on 10/9/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import XCTest
@testable import Introduction

class ContactTests: XCTestCase {
    
    let model = ContactsControllerModel()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testContact1() {
        let contact1 = model.contacts[0]
        XCTAssertEqual(contact1.firstName, "Allan")
        XCTAssertEqual(contact1.lastName, "Munger")
        XCTAssertEqual(contact1.avatarFileName, "Allan Munger.png")
        XCTAssertEqual(contact1.title, "Writer")
    }

    func testContact18() {
        let contact1 = model.contacts[17]
        XCTAssertEqual(contact1.firstName, "Katri")
        XCTAssertEqual(contact1.lastName, "Ahokas")
        XCTAssertEqual(contact1.avatarFileName, "Katri Ahokas.png")
        XCTAssertEqual(contact1.title, "Developer")
    }
}
