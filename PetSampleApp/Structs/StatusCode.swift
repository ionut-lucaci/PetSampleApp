//
//  NetworkError.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import Foundation

typealias StatusCode = Result<Int, StatusCodeError>

extension StatusCode {
    init(intValue: Int) {
        if (100..<400).contains(intValue) {
            self = .success(intValue)
        } else {
            self = .failure(.init(code: intValue))
        }
    }
}

struct StatusCodeError: Error {
    let code: Int
    
    var category: Category? {
        return Category(rawValue: code/100)
    }
    
    var reason: Reason? {
        return Reason(rawValue: code)
    }
    
    enum Category: Int {
        case miscelaneous
        case client = 4 //4xx
        case server = 5 //5xx
    }
    
    enum Reason: Int {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
    }
}



