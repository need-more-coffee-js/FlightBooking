//
//  MockFlightFactory.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation

enum MockFlightFactory {
    static func make(fromScan scan: TicketScan) -> Flight {
        let origin = (scan.origin ?? "MOW")
        let dest   = (scan.destination ?? "IST")
        let airline = "SU"
        let price = Int(scan.price == 0 ? 199 : scan.price)
        let dep = Date()
        let ret = Calendar.current.date(byAdding: .day, value: 7, to: dep)

        return Flight(
            origin: origin,
            destination: dest,
            price: price,
            transfers: 0,
            airlineIATA: airline,
            flightNumber: 1001,
            departure: dep,
            return: ret,
            expires: Calendar.current.date(byAdding: .day, value: 1, to: dep)!,
            currency: "USD"
        )
    }

    static func makeRandomFallback() -> Flight {
        let origins = ["MOW","AMS","IST","LED","AER"]
        let dests   = ["IST","AMS","BCN","PAR","LED"]
        let origin = origins.randomElement()!
        var dest = dests.randomElement()!
        if dest == origin { dest = "IST" }
        let price = [99,149,199,249,299,349].randomElement()!
        let dep = Date()
        let ret = Calendar.current.date(byAdding: .day, value: Int.random(in: 3...10), to: dep)
        return Flight(
            origin: origin,
            destination: dest,
            price: price,
            transfers: Int.random(in: 0...1),
            airlineIATA: ["SU","KL","TK","U6"].randomElement()!,
            flightNumber: Int.random(in: 100...9999),
            departure: dep,
            return: ret,
            expires: dep.addingTimeInterval(3600*24),
            currency: "USD"
        )
    }
}

