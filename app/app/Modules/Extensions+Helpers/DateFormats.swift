//
//  DateFormats.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import Foundation

enum DateFormats {
    static let iso8601: ISO8601DateFormatter = {
        let format = ISO8601DateFormatter()
        format.formatOptions = [.withInternetDateTime]
        return format
    }()
    
    static let dateShort: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "dd MMM yyyy, HH:mm"
        return format
    }()
}

