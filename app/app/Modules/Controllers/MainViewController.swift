//
//  ViewController.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    private let filterBarController = FilterBarController()
    private let table = UITableView(frame: .zero, style: .plain)
    private let loader = UIActivityIndicatorView(style: .large)
    private let api = FlightAPI()
    

    private var params = FlightAPI.Params(currency: "USD", origin: "MOW", destination: "HKT")
    private var selectedDate: Date? = nil
    private var flights: [Flight] = []
    private var priceGroup = PriceGroup(minPrice: 0, midPrice: 0, maxprice: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Билеты  \(params.origin)→\(params.destination)"
        view.backgroundColor = .systemBackground
        setupLayout()
        loadData()
        loadCities()
    }
    
    private func loadCities(){
        CityService.shared.loadCities { [weak self] result in
            switch result {
            case .success:
                self?.setupLayout()
                self?.loadData()
            case .failure(let err):
                print("Не удалось загрузить города:", err)
                self?.setupLayout()
                self?.loadData()
            }
        }
    }
    
    private func setupLayout() {
        filterBarController.delegate = self
        filterBarController.configure(originDisplay: params.origin, destinationDisplay: params.destination, date: selectedDate)

        view.addSubview(filterBarController.view)
        filterBarController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(FlightCell.self, forCellReuseIdentifier: FlightCell.reuseID)
        
        view.addSubview(table)
        table.snp.makeConstraints { make in
            make.top.equalTo(filterBarController.view.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func loadData() {
        loader.startAnimating()
        api.fetchMonthly(params: params) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loader.stopAnimating()
                switch result {
                case .success(let list):
                    self.flights = list
                    self.priceGroup = PriceGroup.from(prices: list.map { $0.price })
                    self.table.reloadData()
                case .failure(let err):
                    self.showError(err)
                }
            }
        }
    }
    
    private func showError(_ err: Error) {
        let alert = UIAlertController(title: "Ошибка", message: err.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
//MARK: - tv extension
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { flights.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flight = flights[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FlightCell.reuseID, for: indexPath) as! FlightCell
        
        let dateText: String = {
            let dep = DateFormats.dateShort.string(from: flight.departure)
            if let ret = flight.return {
                return "Вылет: \(dep)\nОбратно: \(DateFormats.dateShort.string(from: ret))"
            } else {
                return "Вылет: \(dep)"
            }
        }()
        
        let priceText = "\(flight.price) \(flight.currency)"
        let priceColor = priceGroup.color(for: flight.price)
        
        let transfersText: String = {
            switch flight.transfers {
            case 0: return "без пересадок"
            case 1: return "1 пересадка"
            default: return "\(flight.transfers) пересадки"
            }
        }()
        let transfersBG: UIColor = (flight.transfers == 0) ? .systemGreen : .systemBlue
        
        let originTitle = CityService.shared.title(for: flight.origin)
        let destTitle   = CityService.shared.title(for: flight.destination)
        let routeText   = "\(originTitle) → \(destTitle)"
        
        let vm = FlightCell.ViewModel(
            route: routeText,
            airline: "Авиакомпания: \(flight.airlineIATA)",
            dates: dateText,
            priceText: priceText,
            priceColor: priceColor,
            transfersText: transfersText,
            transfersBG: transfersBG
        )
        cell.configure(vm)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("cell tapped")
    }
}
// MARK: - filter
extension MainViewController: FilterBarControllerDelegate {
    func filterBarControllerDidApply(originCode: String, destinationCode: String, date: Date?) {
        params = .init(currency: params.currency, origin: originCode, destination: destinationCode)
        selectedDate = date
        title = "Билеты  \(originCode)→\(destinationCode)"
        loadData()
    }

    func filterBarControllerDidSwap(originDisplay: String, destinationDisplay: String) {
        print("swap destination")
    }

    func filterBarControllerDidFail(_ message: String) {
        showError(NSError(domain: "Filter", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
    }
}
