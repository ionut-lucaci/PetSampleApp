//
//  LocationService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation
import CoreLocation
import RxSwift

protocol LocationService {
    func getLocation() -> Observable<Location>
    // prolly some permission managment is also necessary but ...
}

enum LocationError: Error {
    case wrongPlanet
}

class MockLocationService: LocationService {
    func getLocation() -> Observable<Location> {
//        return .error(LocationError.wrongPlanet)
        return .just(.init(latitude: 37.279138, longitude: -121.950346))
    }
}


