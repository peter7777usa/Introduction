//
//  ContactsControllerModelTests.swift
//  ContactsControllerModelTests
//
//  Created by Peter Fong on 10/9/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import XCTest
@testable import Introduction

class ContactsControllerModelTests: XCTestCase {
    
    let model = ContactsControllerModel()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJSONObjCount() {
        XCTAssertEqual(model.contacts.count, 28)
    }
}
