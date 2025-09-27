//
//  PriceBands.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit

struct PriceGroup {
    let minPrice: Int
    let midPrice: Int
    let maxprice: Int
    
    static func from(prices: [Int]) -> PriceGroup {
        guard !prices.isEmpty else { return .init(minPrice: 0, midPrice: 0, maxprice: 0) }
        let sorted = prices.sorted()
        func qualityPrice(_ procent: Double) -> Int {
            let idx = Int(Double(sorted.count - 1) * procent)
            return sorted[max(0, min(idx, sorted.count - 1))]
        }
        return .init(minPrice: qualityPrice(0.25), midPrice: qualityPrice(0.50), maxprice: qualityPrice(0.75))
    }
    
    func color(for price: Int) -> UIColor {
        if price <= minPrice { return UIColor.systemGreen }
        if price <= midPrice { return UIColor.systemMint }
        if price <= maxprice { return UIColor.systemOrange }
        return UIColor.systemRed
    }
}

