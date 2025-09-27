//
//  Flight.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import Foundation

struct MonthResponseData: Decodable {
    let success: Bool
    let data: [String: MonthItemData] 
    let error: String?
    let currency: String?
}

struct MonthItemData: Decodable {
    let origin: String
    let destination: String
    let price: Int
    let transfers: Int
    let airline: String
    let flight_number: Int?
    let departure_at: String
    let return_at: String?
    let expires_at: String
}

struct Flight: Hashable {
    let origin: String
    let destination: String
    let price: Int
    let transfers: Int
    let airlineIATA: String
    let flightNumber: Int?
    let departure: Date
    let `return`: Date?
    let expires: Date
    let currency: String
    
    var routeText: String { "\(origin) → \(destination)" }
}

