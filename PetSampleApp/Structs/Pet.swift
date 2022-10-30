//
//  Pet.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import Foundation

struct Pet: Decodable, Equatable {
    let id: Int
    let name: String
    let species: String
    let size: Size
    let status: Status
    let distance: Double?
    let photos: [Photo]
    let gender: Gender?
    let breed: Breed?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case size
        case species
        case status
        case distance
        case photos
        case gender
        case breed = "breeds"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        species = try container.decode(String.self, forKey: .species)
        size = try container.decode(Size.self, forKey: .size)
        status = try container.decode(Status.self, forKey: .status)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        photos = try container.decode([Photo].self, forKey: .photos)
        
        do {
            gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        } catch {
            gender = nil
        }
        
        do {
            breed = try container.decode(Breed.self, forKey: .breed)
        } catch Breed.DecodeError.unknown {
            breed = nil
        }
    }
    
    init(id: Int, name: String, species: String, size: Size,
         status: Status, distance: Double? = nil, photos: [Photo] = [],
         gender: Gender? = nil, breed: Breed? = nil)
    {
        self.id = id
        self.name = name
        self.species = species
        self.size = size
        self.status = status
        self.distance = distance
        self.photos = photos
        self.gender = gender
        self.breed = breed
    }
    
    enum Size: String, Decodable, Equatable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        case extraLarge = "Extra Large"
    }
    
    enum Gender: String, Decodable, Equatable {
        case male = "Male"
        case female = "Female"
    }
    
    enum Status: String, Decodable, Equatable {
        case adoptable, adopted, found
    }
    
    enum Breed: Decodable, Equatable {
        case pure(_: String)
        case mixed(primary: String,
                   secondary: String?) // apparently it can be mixed but we don't know the second breed. 😿
        
        enum CodingKeys: String, CodingKey {
            case primary
            case secondary
            case mixed
            case unknown
        }
        
        enum DecodeError: Error {
            case unknown
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if try container.decode(Bool.self, forKey: .unknown) { throw DecodeError.unknown }
            
            let primary = try container.decode(String.self, forKey: .primary)
            
            if try container.decode(Bool.self, forKey: .mixed) {
                self = .mixed(primary: primary,
                              secondary: try container.decodeIfPresent(String.self, forKey: .secondary))
            } else {
                self = .pure(primary)
            }
        }
    }
    
    struct Photo: Decodable, Equatable {
        let small: URL?
        let medium: URL?
        let large: URL?
        let full: URL?
    }
}
