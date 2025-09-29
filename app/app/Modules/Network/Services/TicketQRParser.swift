//
//  TicketQRParser.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation

struct ParsedTicket {
    let origin: String?
    let destination: String?
    let price: Int?
    let currency: String?
    let departureAt: Date?
    let returnAt: Date?
    let airlineIATA: String?
    let flightNumber: Int?
}

enum TicketQRParser {
    static func parse(_ raw: String) -> ParsedTicket {

        if let data = raw.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return ParsedTicket(
                origin: (json["origin"] as? String)?.uppercased(),
                destination: (json["destination"] as? String)?.uppercased(),
                price: (json["price"] as? NSNumber)?.intValue ?? Int(json["price"] as? String ?? ""),
                currency: (json["currency"] as? String)?.uppercased(),
                departureAt: DateFormats.iso8601.date(from: json["departure_at"] as? String ?? ""),
                returnAt: DateFormats.iso8601.date(from: json["return_at"] as? String ?? ""),
                airlineIATA: (json["airline"] as? String)?.uppercased(),
                flightNumber: (json["flight_number"] as? NSNumber)?.intValue ?? Int(json["flight_number"] as? String ?? "")
            )
        }

        return ParsedTicket(
            origin: nil,
            destination: nil,
            price: nil,
            currency: nil,
            departureAt: nil,
            returnAt: nil,
            airlineIATA: nil,
            flightNumber: nil
        )
    }

    static func makeFlight(from parsed: ParsedTicket) -> Flight {
        let origin = parsed.origin ?? "MOW"
        let dest = parsed.destination ?? "IST"
        let dep = parsed.departureAt ?? Date()
        let ret = parsed.returnAt
        let price = parsed.price ?? 199
        let cur = (parsed.currency ?? "USD").uppercased()
        let airline = parsed.airlineIATA ?? "SU"
        let num = parsed.flightNumber ?? 1001
        return Flight(
            origin: origin,
            destination: dest,
            price: price,
            transfers: 0,
            airlineIATA: airline,
            flightNumber: num,
            departure: dep,
            return: ret,
            expires: dep.addingTimeInterval(24*3600),
            currency: cur
        )
    }
}

