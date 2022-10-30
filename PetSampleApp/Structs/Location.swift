//
//  Location.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation

struct Location: Encodable, Equatable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case location
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let value = [String(latitude), String(longitude)].joined(separator: ",")
        
        try container.encode(value, forKey: .location)
    }
}
