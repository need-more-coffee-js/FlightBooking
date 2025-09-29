//
//  ScansStore.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation
import CoreData

final class ScansStore {
    static let shared = ScansStore()
    private let ctx = CoreDataManager.shared.ctx

    func addScan(rawText: String, origin: String? = nil, destination: String? = nil, price: Int? = nil) -> TicketScan? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TicketScan", in: ctx) else { return nil }
        let scan = TicketScan(entity: entity, insertInto: ctx)
        scan.id = UUID()
        scan.rawText = rawText
        scan.createdAt = Date()
        scan.origin = origin
        scan.destination = destination
        scan.price = Int64(price ?? 0)
        CoreDataManager.shared.saveContext()
        return scan
    }

    func delete(_ scan: TicketScan) {
        ctx.delete(scan)
        CoreDataManager.shared.saveContext()
    }
}
