//
//  ContactsControllerModel.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import Foundation
import UIKit

class ContactsControllerModel: NSObject {
    var contacts = [Contact]()
    
    // MARK: - Init Methods
    
    override init() {
        super.init()
        if let contactObjs: [Contact] = JSONHelper.loadJson(filename: "contacts") {
            contacts = contactObjs
        }
    }
}
