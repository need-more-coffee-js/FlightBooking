//
//  CityModel.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation

struct City: Decodable {
    let code: String      
    let name: String
    let name_translations: [String: String]?
    let country_code: String
}
