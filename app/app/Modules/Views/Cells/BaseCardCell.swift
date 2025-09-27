//
//  BaseCardCell.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit
import SnapKit

class BaseCardCell: UITableViewCell {
    let card = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        selectionStyle = .none
        
        contentView.addSubview(card)
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = .init(width: 0, height: 4)
        
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

