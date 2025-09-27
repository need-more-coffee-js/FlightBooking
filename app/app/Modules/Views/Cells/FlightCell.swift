//
//  FlightCell.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit
import SnapKit

final class FlightCell: BaseCardCell {
    static let reuseID = "FlightCell"
    
    private let routeLabel = UILabel()
    private let airlineLabel = UILabel()
    private let datesLabel = UILabel()
    private let priceLabel = UILabel()
    private let transfersBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        routeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        routeLabel.numberOfLines = 1
        
        airlineLabel.font = .systemFont(ofSize: 14)
        airlineLabel.textColor = .secondaryLabel
        
        datesLabel.font = .systemFont(ofSize: 13)
        datesLabel.textColor = .secondaryLabel
        datesLabel.numberOfLines = 2
        
        priceLabel.font = .systemFont(ofSize: 20, weight: .bold)
        priceLabel.textAlignment = .right
        
        transfersBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        transfersBadge.textColor = .white
        transfersBadge.backgroundColor = .systemBlue
        transfersBadge.layer.cornerRadius = 10
        transfersBadge.clipsToBounds = true
        transfersBadge.textAlignment = .center
        transfersBadge.setContentHuggingPriority(.required, for: .horizontal)
        
        card.addSubview(routeLabel)
        card.addSubview(airlineLabel)
        card.addSubview(datesLabel)
        card.addSubview(priceLabel)
        card.addSubview(transfersBadge)
        
        routeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.left.equalToSuperview().inset(14)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-12)
        }
        airlineLabel.snp.makeConstraints { make in
            make.top.equalTo(routeLabel.snp.bottom).offset(4)
            make.left.equalTo(routeLabel)
            make.right.lessThanOrEqualToSuperview().inset(14)
        }
        datesLabel.snp.makeConstraints { make in
            make.top.equalTo(airlineLabel.snp.bottom).offset(6)
            make.left.equalTo(routeLabel)
            make.right.lessThanOrEqualToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(14)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.right.equalToSuperview().inset(14)
        }
        transfersBadge.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel.snp.bottom).offset(14)
            make.right.equalTo(priceLabel)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(60)
        }
    }
    
    struct ViewModel {
        let route: String
        let airline: String
        let dates: String
        let priceText: String
        let priceColor: UIColor
        let transfersText: String
        let transfersBG: UIColor
    }
    
    func configure(_ vm: ViewModel) {
        routeLabel.text = vm.route
        airlineLabel.text = vm.airline
        datesLabel.text = vm.dates
        priceLabel.text = vm.priceText
        priceLabel.textColor = vm.priceColor
        transfersBadge.text = "  \(vm.transfersText)  "
        transfersBadge.backgroundColor = vm.transfersBG
    }
}

