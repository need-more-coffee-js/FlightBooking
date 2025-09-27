//
//  FilterBarView.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import UIKit
import SnapKit

protocol FilterBarViewDelegate: AnyObject {
    func filterBarDidTapApply(origin: String, destination: String, date: Date?)
    func filterBarDidSwap(origin: String, destination: String)
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
    
    private let datePicker = UIDatePicker()
    private let toolbar = UIToolbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDatePicker()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(origin: String, destination: String, date: Date?) {
        originField.text = origin
        destField.text = destination
        if let d = date {
            datePicker.date = d
            dateField.text = Self.dateText(d)
        } else {
            dateField.text = nil
        }
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

        separator.backgroundColor = .separator
        separator.isHidden = true
        
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.plain()
            cfg.baseForegroundColor = .systemBlue
            cfg.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
            cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            swapButton.configuration = cfg
        } else {
            swapButton.setTitle("⇅", for: .normal)
            swapButton.setTitleColor(.systemBlue, for: .normal)
        }
        swapButton.addTarget(self, action: #selector(onSwap), for: .touchUpInside)
        
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.filled()
            cfg.title = "Показать билеты"
            cfg.baseBackgroundColor = .systemBlue
            cfg.baseForegroundColor = .white
            cfg.cornerStyle = .medium
            cfg.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
            applyButton.configuration = cfg
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
    
    private func styleTextField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .tertiarySystemBackground
        tf.layer.cornerRadius = 8
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.autocapitalizationType = .allCharacters
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
    }
    
    private func setupDatePicker() {
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        dateField.inputView = datePicker
        
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDatePicked))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelDate))
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        toolbar.items = [cancel, flex, done]
        dateField.inputAccessoryView = toolbar
    }
    
    @objc private func onDatePicked() {
        dateField.text = Self.dateText(datePicker.date)
        endEditing(true)
    }
    @objc private func onCancelDate() {
        endEditing(true)
    }
    @objc private func onSwap() {
        let o = originField.text ?? ""
        originField.text = destField.text
        destField.text = o
        delegate?.filterBarDidSwap(origin: originField.text ?? "", destination: destField.text ?? "")
    }
    @objc private func onApply() {
        let origin = (originField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let destination = (destField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let date: Date? = dateField.text?.isEmpty == false ? datePicker.date : nil
        delegate?.filterBarDidTapApply(origin: origin, destination: destination, date: date)
    }
    
    private static func dateText(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }
}


