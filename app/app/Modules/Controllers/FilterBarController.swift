//
//  FilterBarController.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import UIKit

protocol FilterBarControllerDelegate: AnyObject {

    func filterBarControllerDidApply(originCode: String, destinationCode: String, date: Date?)
    func filterBarControllerDidSwap(originDisplay: String, destinationDisplay: String)
    func filterBarControllerDidFail(_ message: String)
}

final class FilterBarController: NSObject {
    weak var delegate: FilterBarControllerDelegate?

    let view = FilterBarView()

    private var selectedDate: Date? = nil

    private let datePicker = UIDatePicker()
    private let toolbar = UIToolbar()

    override init() {
        super.init()
        view.delegate = self
        setupDatePicker()
    }

    func configure(originDisplay: String, destinationDisplay: String, date: Date?) {
        view.setOrigin(originDisplay)
        view.setDestination(destinationDisplay)
        selectedDate = date
        view.setDateText(date.map { Self.formatDate($0) })
    }

    private func setupDatePicker() {
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()

        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDatePicked))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelDate))
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        toolbar.items = [cancel, flex, done]

        view.setDateFieldInputView(datePicker, accessory: toolbar)
    }

    @objc private func onDatePicked() {
        selectedDate = datePicker.date
        view.setDateText(Self.formatDate(datePicker.date))
        view.endEditing(true)
    }
    @objc private func onCancelDate() {
        view.endEditing(true)
    }

    private static func formatDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }

    private func resolveCityCode(from userInput: String) -> String? {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count == 3, trimmed.uppercased() == trimmed { // уже IATA
            return trimmed
        }

        return CityService.shared.findIATA(for: trimmed).first?.code
    }
}


extension FilterBarController: FilterBarViewDelegate {
    func filterBarViewDidBeginEditDate() {
    }

    func filterBarViewDidTapSwap() {
        let o = view.getOrigin()
        let d = view.getDestination()
        view.setOrigin(d)
        view.setDestination(o)
        delegate?.filterBarControllerDidSwap(originDisplay: d, destinationDisplay: o)
    }

    func filterBarViewDidTapApply() {
        let originDisplay = view.getOrigin()
        let destDisplay   = view.getDestination()

        guard let oCode = resolveCityCode(from: originDisplay),
              let dCode = resolveCityCode(from: destDisplay) else {
            delegate?.filterBarControllerDidFail("Не удалось найти город. Введите название (например, «Москва») или IATA (MOW).")
            return
        }
        delegate?.filterBarControllerDidApply(originCode: oCode, destinationCode: dCode, date: selectedDate)
    }
}

