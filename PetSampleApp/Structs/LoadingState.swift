//
//  LoadingState.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import Foundation

enum LoadingState: Equatable {
    case loaded(empty: Bool)
    case loading
    case error(message: String)
    
    var hasActivity: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var state: String? {
        switch self {
        case .loaded(let empty):
            return (empty ? "No items" : nil)
        case .loading:
            return "Loading..."
        case .error:
            return "Error:"
        }
    }
    
    var message: String? {
        switch self {
        case .error(message: let msg):
            return msg
        default:
            return nil
        }
    }
}
