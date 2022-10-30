//
//  PetsViewModel.swift
//  PetSample
//
//  Created by Ionut Lucaci on 25.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

typealias PetItem = PetsViewModel.Item
typealias PetSection = SectionModel<String, PetItem>

class PetsViewModel {
    // MARK: - In
    let itemSelected = PublishRelay<Item>()
    
    // MARK: - Out
    let sections = BehaviorRelay<[PetSection]>(value: [])
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let toast = ReplayRelay<String>.create(bufferSize: 1)
    
    // MARK: - Structs
    struct Item {
        let pet: Pet
        let distanceFormatter: NumberFormatter
        let photo: Observable<UIImage>
    }
    
    // MARK: - Boilerplate
    let disposeBag = DisposeBag()
    
    // MARK: - Methods
    init(petService: PetAPIService, locationService: LocationService, mediaService: MediaSevice, navigator: Navigator) {
        let location = locationService
            .getLocation()
            .share()
        
        location
            .materialize()
            .errors()
            .map { "Error determining your location.\nShowing all pets.\nError info: '\($0)'"}
            .bind(to: toast)
            .disposed(by: disposeBag)
                
        let pets = location
            .map { $0 }
            .catch { _ in .just(nil) }
            .flatMap { petService
                .getPets(location: $0)
                .materialize()
            }
            .share()
                
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        pets
            .elements()
            .mapElements { PetItem(pet: $0,
                                   distanceFormatter: formatter,
                                   photo: mediaService.getPhoto(url: $0.photos.first?.small)) }
    
            .map { $0.sorted().sectioned() }
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        pets
            .elements()
            .map { LoadingState.loaded(empty: $0.isEmpty) }
            .bind(to: loadingState)
            .disposed(by: disposeBag)
        
        pets
            .errors()
            .map { LoadingState.error(message: String(describing: $0)) }
            .bind(to: loadingState)
            .disposed(by: disposeBag)
        
        itemSelected
            .map { Navigation.Source.petList(event: .showDetails($0)) }
            .bind(to: navigator.sourceEvent)
            .disposed(by: disposeBag)
    }
}

// MARK: - Extensions

extension PetItem {
    enum DistanceFormat {
        case short
        case long
    }
    
    func distanceText(format: DistanceFormat = .short) -> String? {
        switch format {
        case .short:
            return formattedDistance.map { $0 + " mi." }
        case .long:
            return formattedDistance.map { $0 + " miles away from you" }
        }
    }

    var formattedDistance: String? {
        guard let distance = pet.distance else { return nil }
        return distanceFormatter.string(from: NSNumber(value: distance)) ?? String(distance)
    }
    
    var detailText: String? {
        return [pet.species, pet.breed?.textual]
            .compactMap { $0 }
            .joined(separator: ": ")
    }
    
    var emoji: String {
        switch pet.species.lowercased() {
        case "cat":
            return "🐱"
        case "dog":
            return "🐶"
        case "parrot":
            return "🦜"
        case "hamster", "guinea pig":
            return "🐹"
        case "fish":
            return "🐠"
        case "chicken":
            return "🐔"
        case "rabbit", "bunny":
            return "🐰"
        default:
            return "🐾"
        }
    }
}

extension Pet.Breed {
    var textual: String {
        switch self {
        case .pure(let breed):
            return breed
        case .mixed(let primary, let secondary):
            let mix = [primary, secondary]
                .compactMap { $0 }
                .joined(separator: " + ")
            
            return "Mixed (\(mix))"
        }
    }
}

extension PetItem: Equatable, Comparable {
    static func == (lhs: PetsViewModel.Item, rhs: PetsViewModel.Item) -> Bool {
        return lhs.pet == rhs.pet
    }
    
    static func < (lhs: PetItem, rhs: PetItem) -> Bool {
        if lhs.pet.distance == rhs.pet.distance { // either equal values or both null
            return lhs.pet.name < rhs.pet.name
        }
        
        if let d1 = lhs.pet.distance, let d2 = rhs.pet.distance { // happy case: simple distance comparisson
            return d1 < d2
        }
        
        // By now one of them is null and the other is not.
        // Pets with unknown location are last, thus they're in order if the 2nd one is null.
        return (rhs.pet.distance == nil)
    }
}

extension PetItem: Sectionable {
    var sectionedBy: String {
        guard let distance = pet.distance else { return "unknown location" }
        
        let distanceClassses = [2, 5, 10, 20, 50, 100]
        for distanceClass in distanceClassses {
            if distance < Double(distanceClass) {
                return "less than \(distanceClass) miles away"
            }
        }
        
        return "more than \(distanceClassses.last ?? 0) miles away"
    }
}
