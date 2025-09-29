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
    
    private var byCode: [String: City] = [:]
    private var prepared: [(ru: String, en: String, code: String)] = [] // для быстрого поиска
    private let prepQueue = DispatchQueue(label: "cities.prep", qos: .userInitiated)
    
    func loadCities(completion: @escaping (Result<[City], Error>) -> Void) {
        guard let url = URL(string: "https://api.travelpayouts.com/data/en/cities.json") else {
            completion(.failure(NSError(domain: "City", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Bad URL"])))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "City", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let cities = try JSONDecoder().decode([City].self, from: data)
                
                self.prepQueue.async {
                    let byCode = Dictionary(uniqueKeysWithValues:
                                                cities.map { ($0.code.uppercased(), $0) })
                    
                    func norm(_ s: String) -> String {
                        s.folding(options: [.diacriticInsensitive, .caseInsensitive],
                                  locale: .current)
                    }
                    
                    var prepared: [(ru: String, en: String, code: String)] = []
                    prepared.reserveCapacity(cities.count)
                    
                    for c in cities {
                        let en = norm(c.name)
                        let ru = norm(c.name_translations?["ru"] ?? c.name)
                        prepared.append((ru: ru, en: en, code: c.code.uppercased()))
                    }
                    
                    DispatchQueue.main.async {
                        self.cities = cities
                        self.byCode = byCode
                        self.prepared = prepared
                        self.dict = byCode
                        completion(.success(cities))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func findAsync(query: String, limit: Int = 10, completion: @escaping ([City]) -> Void) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            completion([])
            return
        }
        
        let normalized = q.folding(options: [.diacriticInsensitive, .caseInsensitive],
                                   locale: .current)
        
        prepQueue.async {
            let hits = self.prepared.lazy
                .filter { $0.ru.contains(normalized) || $0.en.contains(normalized) }
                .prefix(limit)
                .compactMap { self.byCode[$0.code] }
            
            DispatchQueue.main.async { completion(Array(hits)) }
        }
    }
    
    func title(for code: String) -> String {
        guard let city = dict[code.uppercased()] else { return code }
        if let ru = city.name_translations?["ru"], !ru.isEmpty { return ru }
        return city.name
    }
}
