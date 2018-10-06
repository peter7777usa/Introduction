//
//  Contact.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import Foundation

class Contact: Decodable {
    let firstName: String
    let lastName: String
    let avatarFileName: String
    let title: String
    let introduction: String
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarFileName = "avatar_filename"
        case title
        case introduction
    }
    
    // MARK: - Init methods
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.avatarFileName = try container.decode(String.self, forKey: .avatarFileName)
        self.title = try container.decode(String.self, forKey: .title)
        self.introduction = try container.decode(String.self, forKey: .introduction)
    }
}
