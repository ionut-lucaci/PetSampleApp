//
//  Endpoint.swift
//  PetSample
//
//  Created by Ionut Lucaci on 25.10.2022.
//

import Foundation

enum Endpoint: Equatable {
    case petfinder(_: Petfinder, environment: Environment = .prod)
    case photo(url: URL)
    
    enum Petfinder: String, Equatable {
        case auth = "oauth2/token"
        case pets = "animals"
    }
    
    enum Environment: Equatable {
        case prod
    }
    
    var base: String {
        switch self {
        case .petfinder(_, let env):
            switch env {
            case .prod:
                return "https://api.petfinder.com/v2/"
            }
        case .photo(url: let url):
            return url.absoluteString
        }
    }
    
    var path: String? {
        switch self {
        case .petfinder(let endpoint, _):
            return endpoint.rawValue
        case .photo:
            return nil
        }
    }
    
    var url: String {
        return base + (path ?? "")
    }
}
