//
//  NetworkDTOs.swift
//  PetSample
//
//  Created by Ionut Lucaci on 25.10.2022.
//

import Foundation

enum Header: String, Equatable {
    case auth = "Authorization"
    
    enum Value {
        case token(_: OAuth.Token)
        
        var value: String {
            switch self {
            case .token(let token):
                return "Bearer \(token.value)"
            }
        }
    }
}
