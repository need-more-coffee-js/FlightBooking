//
//  FlightAPI.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import Foundation

final class FlightAPI {
    private let session: URLSession = .shared
    private let base = "https://api.travelpayouts.com/v1/prices/monthly"

    struct Params {
        let currency: String
        let origin: String
        let destination: String
    }
    
    func fetchMonthly(params: Params, completion: @escaping (Result<[Flight], Error>) -> Void) {
        guard let token = TokenLoader.travelpayouts() else {
            completion(.failure(APIError.noToken)); return
        }
        var comps = URLComponents(string: base)
        comps?.queryItems = [
            .init(name: "currency", value: params.currency),
            .init(name: "origin", value: params.origin),
            .init(name: "destination", value: params.destination),
            .init(name: "token", value: token)
        ]
        guard let url = comps?.url else { completion(.failure(APIError.badURL)); return }
        
        session.dataTask(with: url) { data, resp, err in
            if let err = err { completion(.failure(APIError.transport(err))); return }
            guard let http = resp as? HTTPURLResponse else {
                completion(.failure(APIError.badStatus(-1))); return
            }
            guard (200..<300).contains(http.statusCode), let data = data else {
                completion(.failure(APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1))); return
            }
            do {
                let dto = try JSONDecoder().decode(MonthResponseData.self, from: data)
                if dto.success == false {
                    completion(.failure(APIError.backend(dto.error ?? "error"))); return
                }
                let currency = dto.currency ?? "USD"

                let flights: [Flight] = dto.data.values.compactMap { item in
                    guard let dep = DateFormats.iso8601.date(from: item.departure_at),
                          let exp = DateFormats.iso8601.date(from: item.expires_at)
                    else { return nil }
                    let ret: Date? = item.return_at.flatMap { DateFormats.iso8601.date(from: $0) }
                    return Flight(
                        origin: item.origin,
                        destination: item.destination,
                        price: item.price,
                        transfers: item.transfers,
                        airlineIATA: item.airline,
                        flightNumber: item.flight_number,
                        departure: dep,
                        return: ret,
                        expires: exp,
                        currency: currency
                    )
                }
                
                let sorted = flights.sorted { $0.price < $1.price }
                completion(.success(sorted))
            } catch {
                completion(.failure(APIError.decode))
            }
        }.resume()
    }
}

