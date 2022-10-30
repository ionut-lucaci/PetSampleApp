//
//  PetDetailsViewModel.swift
//  PetSample
//
//  Created by Ionut Lucaci on 28.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

typealias PetDetailItem = PetDetailsViewModel.Item
typealias PetDetailSection = SectionModel<String?, PetDetailItem>

class PetDetailsViewModel {
    // MARK: - Out
    let title = BehaviorRelay<String?>(value: nil)
    let sections = BehaviorRelay<[PetDetailSection]>(value: [])
    
    // MARK: - Boilerplate
    let disposeBag = DisposeBag()
    
    // MARK: - Structs
    enum Item {
        case header(petItem: PetItem)
        case key(_ key: String?, value: String?)
    }
    
    // MARK: - Methods
    init(navigator: Navigator) {
        // Display a details screen for each item - name, breed, size, gender, status, distance.
        let petItem = navigator
            .destinationData
            .map { $0.ofType(PetItem.self) }
            .unwrap()

        petItem
            .map { $0.pet.name }
            .bind(to: title)
            .disposed(by: disposeBag)
        
        petItem
            .map { [PetDetailSection(model: nil,
                                     items: [.header(petItem: $0)]), // species + breed + distance
                    PetDetailSection(model: nil,
                                     items: [.key("Size",
                                                  value: $0.pet.size.rawValue.lowercased()),
                                             .key("Gender",
                                                  value: $0.pet.gender?.rawValue.lowercased() ?? "unknown"),
                                             .key("Status",
                                                  value: $0.pet.status.rawValue)])] }
            .bind(to: sections)
            .disposed(by: disposeBag)
    }
}

// MARK: - Extensions

extension PetDetailItem {
    enum ReuseId: String {
        case header = "PetDetailHeaderCell"
        case keyValue = "PetDetailKeyValueCell"
    }
    
    var reuseId: ReuseId {
        switch self {
        case .header:
            return .header
        case .key:
            return .keyValue
        }
    }
}
