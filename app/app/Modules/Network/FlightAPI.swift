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
    private let popularDirectionsBase = "https://api.travelpayouts.com/v1/city-directions"

    struct Params {
        let currency: String
        let origin: String
        let destination: String
    }

    private func makeURL(_ base: String, _ items: [URLQueryItem]) -> URL? {
        var comps = URLComponents(string: base)
        comps?.queryItems = items
        return comps?.url
    }

    private func handleHTTP(_ resp: URLResponse?, _ data: Data?) -> Result<Data, APIError> {
        guard let http = resp as? HTTPURLResponse else { return .failure(.badStatus(-1)) }
        guard (200..<300).contains(http.statusCode), let data = data else {
            return .failure(.badStatus(http.statusCode))
        }
        return .success(data)
    }

    func fetchMonthly(params: Params, completion: @escaping (Result<[Flight], Error>) -> Void) {
        guard let token = TokenLoader.travelpayouts() else {
            completion(.failure(APIError.noToken))
            return
        }

        guard let url = makeURL(base, [
            .init(name: "currency", value: params.currency),
            .init(name: "origin", value: params.origin),
            .init(name: "destination", value: params.destination),
            .init(name: "token", value: token)
        ]) else {
            completion(.failure(APIError.badURL))
            return
        }

        session.dataTask(with: url) { data, resp, err in
            if let err = err {
                completion(.failure(APIError.transport(err)))
                return
            }
            switch self.handleHTTP(resp, data) {
            case .failure(let e):
                completion(.failure(e))
            case .success(let data):
                do {
                    let dto = try JSONDecoder().decode(MonthResponseData.self, from: data)
                    guard dto.success else {
                        completion(.failure(APIError.backend(dto.error ?? "error")))
                        return
                    }
                    let currency = (dto.currency ?? params.currency).uppercased()
                    let flights: [Flight] = dto.data.values.compactMap { item in
                        guard
                            let dep = DateFormats.iso8601.date(from: item.departure_at),
                            let exp = DateFormats.iso8601.date(from: item.expires_at)
                        else { return nil }
                        let ret = item.return_at.flatMap { DateFormats.iso8601.date(from: $0) }
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
                    }.sorted { $0.price < $1.price }
                    completion(.success(flights))
                } catch {
                    completion(.failure(APIError.decode))
                }
            }
        }.resume()
    }

    func fetchPopularCityDirections(origin: String,
                                    currency: String,
                                    completion: @escaping (Result<[Flight], Error>) -> Void) {
        guard let token = TokenLoader.travelpayouts() else {
            completion(.failure(APIError.noToken))
            return
        }

        guard let url = makeURL(popularDirectionsBase, [
            .init(name: "origin", value: origin),
            .init(name: "currency", value: currency.lowercased()),
            .init(name: "token", value: token)
        ]) else {
            completion(.failure(APIError.badURL))
            return
        }

        session.dataTask(with: url) { data, resp, err in
            if let err = err {
                completion(.failure(APIError.transport(err)))
                return }
            switch self.handleHTTP(resp, data) {
            case .failure(let e):
                completion(.failure(e))
            case .success(let data):
                do {
                    let dto = try JSONDecoder().decode(MonthResponseData.self, from: data)
                    guard dto.success else {
                        completion(.failure(APIError.backend(dto.error ?? "error")))
                        return
                    }
                    let outCurrency = (dto.currency ?? currency).uppercased()
                    let flights: [Flight] = dto.data.values.compactMap { item in
                        let dep = DateFormats.iso8601.date(from: item.departure_at) ?? Date()
                        let ret = item.return_at.flatMap { DateFormats.iso8601.date(from: $0) }
                        let exp = DateFormats.iso8601.date(from: item.expires_at) ?? Date()
                        return Flight(
                            origin: item.origin,
                            destination: item.destination,
                            price: item.price,
                            transfers: item.transfers,
                            airlineIATA: item.airline,
                            flightNumber: item.flight_number ?? 0,
                            departure: dep,
                            return: ret,
                            expires: exp,
                            currency: outCurrency
                        )
                    }.sorted { $0.price < $1.price }
                    completion(.success(flights))
                } catch {
                    completion(.failure(APIError.decode))
                }
            }
        }.resume()
    }
}
