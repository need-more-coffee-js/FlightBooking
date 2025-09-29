//
//  FlightDetailsViewController.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import UIKit
import SnapKit

final class FlightDetailsViewController: UIViewController {
    private let flight: Flight
    
    private let grabber = UIView()
    private let titleLabel = UILabel()
    private let routeLabel = UILabel()
    private let airlineLabel = UILabel()
    private let datesLabel = UILabel()
    private let transfersLabel = UILabel()
    private let priceLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    init(flight: Flight) {
        self.flight = flight
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        if #available(iOS 15, *) {} else {
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .coverVertical
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.text = "Подробности рейса"
        
        routeLabel.font = .systemFont(ofSize: 20, weight: .bold)
        routeLabel.numberOfLines = 0
        
        airlineLabel.font = .systemFont(ofSize: 15)
        airlineLabel.textColor = .secondaryLabel
        
        datesLabel.font = .systemFont(ofSize: 15)
        datesLabel.textColor = .secondaryLabel
        datesLabel.numberOfLines = 0
        
        transfersLabel.font = .systemFont(ofSize: 15)
        transfersLabel.textColor = .secondaryLabel
        
        priceLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        priceLabel.textAlignment = .right
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Перейти к билетам"
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .large
            config.contentInsets = .init(top: 14, leading: 16, bottom: 14, trailing: 16)
            actionButton.configuration = config
        } else {
            actionButton.setTitle("Перейти к билетам", for: .normal)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.backgroundColor = .systemBlue
            actionButton.layer.cornerRadius = 14
            actionButton.contentEdgeInsets = .init(top: 14, left: 16, bottom: 14, right: 16)
        }
        actionButton.addTarget(self, action: #selector(onBook), for: .touchUpInside)
        
        let content = UIView()
        view.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        content.addSubview(titleLabel)
        content.addSubview(routeLabel)
        content.addSubview(airlineLabel)
        content.addSubview(datesLabel)
        content.addSubview(transfersLabel)
        content.addSubview(priceLabel)
        content.addSubview(actionButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        routeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        airlineLabel.snp.makeConstraints { make in
            make.top.equalTo(routeLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        datesLabel.snp.makeConstraints { make in
            make.top.equalTo(airlineLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        transfersLabel.snp.makeConstraints { make in
            make.top.equalTo(datesLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(transfersLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onClose)
        )
    }
    
    private func fillData() {
        let originTitle = CityService.shared.title(for: flight.origin)
        let destTitle   = CityService.shared.title(for: flight.destination)
        routeLabel.text = "\(originTitle) → \(destTitle)"
        
        airlineLabel.text = "Авиакомпания: \(flight.airlineIATA)"
        
        let dep = DateFormats.dateShort.string(from: flight.departure)
        let ret = flight.return.map { DateFormats.dateShort.string(from: $0) }
        datesLabel.text = ret != nil ? "Туда: \(dep)\nОбратно: \(ret!)" : "Вылет: \(dep)"
        
        let transfersText: String = {
            switch flight.transfers {
            case 0: return "Без пересадок"
            case 1: return "1 пересадка"
            default: return "\(flight.transfers) пересадки"
            }
        }()
        transfersLabel.text = transfersText
        
        priceLabel.text = "\(flight.price) \(flight.currency)"
    }
    
    @objc private func onClose() { dismiss(animated: true) }
    @objc private func onBook() {
        print("url redirect")
        dismiss(animated: true)
    }
}

