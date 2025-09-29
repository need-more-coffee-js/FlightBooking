//
//  CityServices.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation

final class CityService {
    static let shared = CityService()
    
    private(set) var cities: [City] = []
    private var dict: [String: City] = [:] 
    
    func loadCities(completion: @escaping (Result<[City], Error>) -> Void) {
        guard let url = URL(string: "https://api.travelpayouts.com/data/en/cities.json") else {
            completion(.failure(NSError(domain: "City", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad URL"])))
            return
        }
        URLSession.shared.dataTask(with: url) { data, resp, err in
            if let err = err {
                completion(.failure(err)); return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "City", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let cities = try JSONDecoder().decode([City].self, from: data)
                DispatchQueue.main.async {
                    self.cities = cities
                    self.dict = Dictionary(uniqueKeysWithValues: cities.map { ($0.code.uppercased(), $0) })
                    completion(.success(cities))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func title(for code: String) -> String {
        guard let city = dict[code.uppercased()] else { return code }
        if let ru = city.name_translations?["ru"], !ru.isEmpty {
            return ru
        }
        return city.name
    }
    
    func findIATA(for namePart: String) -> [City] {
        let lower = namePart.lowercased()
        return cities.filter { city in
            city.name.lowercased().contains(lower) ||
            (city.name_translations?["ru"]?.lowercased().contains(lower) ?? false)
        }
    }
}
