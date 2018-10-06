//
//  JSONHelper.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

class JSONHelper: NSObject {
    static func loadJson<T>(filename fileName: String) -> T? where T: Decodable {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(T.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}
