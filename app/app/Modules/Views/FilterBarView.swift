//
//  FilterBarView.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit
import SnapKit

protocol FilterBarViewDelegate: AnyObject {
    func filterBarViewDidTapSwap()
    func filterBarViewDidTapApply()
    func filterBarViewDidBeginEditDate()
}

final class FilterBarView: UIView {
    weak var delegate: FilterBarViewDelegate?

    private let card = UIView()
    private let originField = UITextField()
    private let destField = UITextField()
    private let separator = UIView()
    private let swapButton = UIButton(type: .system)
    private let dateField = UITextField()
    private let applyButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setOrigin(_ text: String?) { originField.text = text }
    func setDestination(_ text: String?) { destField.text = text }
    func setDateText(_ text: String?) { dateField.text = text }

    func getOrigin() -> String { (originField.text ?? "") }
    func getDestination() -> String { (destField.text ?? "") }
    func getDateText() -> String { (dateField.text ?? "") }

    func setDateFieldInputView(_ view: UIView?, accessory: UIView?) {
        dateField.inputView = view
        dateField.inputAccessoryView = accessory
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(card)
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = .init(width: 0, height: 4)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        styleTextField(originField, placeholder: "Откуда")
        styleTextField(destField,   placeholder: "Куда")
        styleTextField(dateField,   placeholder: "Дата вылета")
        dateField.delegate = self

        separator.backgroundColor = .separator
        separator.isHidden = true

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .systemBlue
            config.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            swapButton.configuration = config
        } else {
            swapButton.setTitle("⇅", for: .normal)
            swapButton.setTitleColor(.systemBlue, for: .normal)
        }
        swapButton.addTarget(self, action: #selector(onSwap), for: .touchUpInside)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Показать билеты"
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            config.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
            applyButton.configuration = config
        } else {
            applyButton.setTitle("Показать билеты", for: .normal)
            applyButton.setTitleColor(.white, for: .normal)
            applyButton.backgroundColor = .systemBlue
            applyButton.layer.cornerRadius = 12
            applyButton.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        }
        applyButton.addTarget(self, action: #selector(onApply), for: .touchUpInside)

        let routesStack = UIView()
        card.addSubview(routesStack)
        routesStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.left.right.equalToSuperview().inset(14)
        }

        routesStack.addSubview(originField)
        routesStack.addSubview(separator)
        routesStack.addSubview(destField)
        routesStack.addSubview(swapButton)

        originField.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(originField.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        destField.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        swapButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(separator.snp.centerY)
            make.width.height.equalTo(36)
        }

        card.addSubview(dateField)
        card.addSubview(applyButton)
        dateField.snp.makeConstraints { make in
            make.top.equalTo(routesStack.snp.bottom).offset(10)
            make.left.right.equalTo(routesStack)
            make.height.equalTo(44)
        }
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(dateField.snp.bottom).offset(14)
            make.left.right.equalTo(routesStack)
            make.bottom.equalToSuperview().inset(14)
            make.height.equalTo(48)
        }
    }

    private func styleTextField(_ textf: UITextField, placeholder: String) {
        textf.placeholder = placeholder
        textf.borderStyle = .none
        textf.backgroundColor = .tertiarySystemBackground
        textf.layer.cornerRadius = 8
        textf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textf.leftViewMode = .always
        textf.autocorrectionType = .no
        textf.clearButtonMode = .whileEditing
    }

    @objc private func onSwap(){
        delegate?.filterBarViewDidTapSwap()
    }
    @objc private func onApply(){
        delegate?.filterBarViewDidTapApply()
    }
}

extension FilterBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === dateField {
            delegate?.filterBarViewDidBeginEditDate()
        }
    }
}



