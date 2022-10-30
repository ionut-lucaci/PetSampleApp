//
//  Method.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import Foundation

// We might be overdoing it here but if we truly want to decouple from AF it might be the only way
enum Method: Equatable {
    case get
    case post
    case put
    case patch
    case delete
}
