//
//  ScansHistoryViewController.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import UIKit
import CoreData

final class ScansHistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private lazy var fetchReq: NSFetchedResultsController<TicketScan> = {
        let req: NSFetchRequest<TicketScan> = TicketScan.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: req,
                                             managedObjectContext: CoreDataManager.shared.ctx,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "История билетов"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        do { try fetchReq.performFetch() } catch { print("FRC error:", error) }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchReq.sections?[section].numberOfObjects ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int { fetchReq.sections?.count ?? 1 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scan = fetchReq.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        let date = DateFormatter.localizedString(from: scan.createdAt ?? Date.now, dateStyle: .medium, timeStyle: .short)
        let route = [scan.origin, scan.destination].compactMap{$0}.joined(separator: " → ")
        cfg.text = route.isEmpty ? "Скан: \(String(describing: scan.rawText?.prefix(32)))..." : route
        cfg.secondaryText = date
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Удалить") { _,_,done in
            let scan = self.fetchReq.object(at: indexPath)
            ScansStore.shared.delete(scan)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scan = fetchReq.object(at: indexPath)
        let flight = MockFlightFactory.make(fromScan: scan)
        let vc = FlightDetailsViewController(flight: flight)
        let nav = UINavigationController(rootViewController: vc)
        if #available(iOS 15.0, *) {
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.detents = [.medium(), .large()]
            nav.sheetPresentationController?.prefersGrabberVisible = true
            nav.sheetPresentationController?.preferredCornerRadius = 20
        }
        present(nav, animated: true)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

