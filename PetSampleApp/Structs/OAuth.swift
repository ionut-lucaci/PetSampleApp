//
//  OAuth.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import Foundation

struct OAuth {
    struct Credentials: Encodable, Equatable {
        enum GrantType: String, Encodable, Equatable {
            case clientCredentials = "client_credentials"
        }
        
        let grantType: GrantType = .clientCredentials
        let clientId: String
        let clientSecret: String
        
        enum CodingKeys: String, CodingKey {
            case grantType = "grant_type"
            case clientId = "client_id"
            case clientSecret = "client_secret"
        }
    }

    struct Token: Decodable, Equatable {
        let value: String
        let expiresIn: Int
        
        enum CodingKeys: String, CodingKey {
            case value = "access_token"
            case expiresIn = "expires_in"
        }
    }
}
