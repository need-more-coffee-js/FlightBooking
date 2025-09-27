//
//  TokenLoader.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import Foundation

enum TokenLoader {
    static func travelpayouts() -> String? {
        guard
            let url = Bundle.main.url(forResource: "Token", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let token = dict["TRAVELPAYOUTS_TOKEN"] as? String,
            token.isEmpty == false
        else { return nil }
        return token
    }
}

