//
//  NavigationService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 28.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Interface
protocol Navigator {
    // MARK: - In
    var sourceEvent: PublishRelay<Navigation.Source> { get }
    
    // MARK: - Out
    var transition: PublishRelay<Navigation.Transition> { get }
    var destinationData: ReplayRelay<Navigation.Destination> { get }
}

// MARK: - Implementation
class PetSampleNavigator: Navigator {
    // MARK: - In
    let sourceEvent = PublishRelay<Navigation.Source>()
    
    // MARK: - Out
    var transition = PublishRelay<Navigation.Transition>()
    var destinationData = ReplayRelay<Navigation.Destination>.create(bufferSize: 1)
    
    // MARK: - Boilerplate
    let disposeBag = DisposeBag()
    
    init() {
        sourceEvent
            .map { $0.transition }
            .bind(to: transition)
            .disposed(by: disposeBag)
        
        sourceEvent
            .map { $0.destinationData }
            .bind(to: destinationData)
            .disposed(by: disposeBag)
    }
}

fileprivate extension Navigation.Source {
    var transition: Navigation.Transition {
        switch self {
        case .petList(event: let event):
            switch event {
            case .showDetails:
                return .init(source: .PetsViewController,
                             style: .segue(id: .showPetDetails))
            }
        }
    }
    
    var destinationData: Navigation.Destination {
        switch self {
        case .petList(event: let event):
            switch event {
            case .showDetails(let details):
                return .petDetails(data: details)
            }
        }
    }
}

extension Navigation.Destination {
    func ofType<T>(_ type: T.Type) -> T? {
        switch self {
        case .petDetails(data: let item):
            if item is T { return item as? T }
        }
        
        return nil
    }
}
