//
//  Errors.swift
//  app
//
//  Created by Денис Ефименков on 27.09.2025.
//

import Foundation

enum APIError: Error {
    case noToken
    case badURL
    case transport(Error)
    case badStatus(Int)
    case decode
    case backend(String)
}
