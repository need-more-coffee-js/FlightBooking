//
//  CoreDataManager.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "TicketScan")
        c.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
        return c
    }()

    var ctx: NSManagedObjectContext { container.viewContext }

    func saveContext() {
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            print("CoreData save error:", error)
        }
    }
}
