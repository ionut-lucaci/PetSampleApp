//
//  PetSampleTests.swift
//  PetSampleTests
//
//  Created by Ionut Lucaci on 24.10.2022.
//

import XCTest
import RxSwift
import RxCocoa
import RxDataSources
import RxBlocking
import RxTest

@testable import PetSampleApp

class PetsViewModelTests: XCTestCase {
    var scheduler: TestScheduler! = nil
    var disposeBag: DisposeBag!
    
    var petService: MockPetAPIService! = nil
    var navigator: MockNavigator! = nil
    var testSubject: PetsViewModel! = nil

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        petService = MockPetAPIService()
        navigator = MockNavigator()
        testSubject = PetsViewModel(petService: petService,
                                    locationService: MockLocationService(),
                                    mediaService: MockMediaService(),
                                    navigator: navigator)
    }

    override func tearDownWithError() throws {}

    func testNoPets() throws {
        let sectionsObserver = scheduler.createObserver([PetSection].self)
        testSubject
            .sections
            .bind(to: sectionsObserver)
            .disposed(by: disposeBag)
        
        let loadingStateObserver = scheduler.createObserver(LoadingState.self)
        testSubject
            .loadingState
            .bind(to: loadingStateObserver)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, [])])
            .bind(to: petService.pets)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(sectionsObserver.events, [.next(0, []),
                                                 .next(10, [])])
        XCTAssertEqual(loadingStateObserver.events, [.next(0, .loading),
                                                     .next(10, .loaded(empty: true))])
    }
    
    func testPets() throws {
        let sectionsObserver = scheduler.createObserver([PetSection].self)
        testSubject
            .sections
            .bind(to: sectionsObserver)
            .disposed(by: disposeBag)
        
        let loadingStateObserver = scheduler.createObserver(LoadingState.self)
        testSubject
            .loadingState
            .bind(to: loadingStateObserver)
            .disposed(by: disposeBag)

        let comodorePet = Pet(id: 0,
                              name: "Comodore",
                              species: "Computer",
                              size: .medium,
                              status: .adopted,
                              distance: 15)
        
        let plasticPet = Pet(id: 1,
                             name: "Plastic",
                             species: "Recyclable",
                             size: .small,
                             status: .found,
                             distance: 1000)
        
        let petre = Pet(id: 2,
                        name: "Petre",
                        species: "Fabulist si epigramist",
                        size: .large,
                        status: .adoptable)
        
        scheduler
            .createColdObservable([.next(10, [comodorePet, plasticPet, petre])])
            .bind(to: petService.pets)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(sectionsObserver.events, [
            .next(0, []),
            .next(10, [
                PetSection(model: "less than 20 miles away",
                           items: [PetItem(pet: comodorePet,
                                           distanceFormatter: NumberFormatter(),
                                           photo: .never())]),
                PetSection(model: "more than 100 miles away",
                           items: [PetItem(pet: plasticPet,
                                           distanceFormatter: NumberFormatter(),
                                           photo: .never())]),
                PetSection(model: "unknown location",
                           items: [PetItem(pet: petre,
                                           distanceFormatter: NumberFormatter(),
                                           photo: .never())])
            ])
        ])
        
        XCTAssertEqual(loadingStateObserver.events, [.next(0, .loading),
                                                     .next(10, .loaded(empty: false))])
    }
    
    func testError() throws {
        let sectionsObserver = scheduler.createObserver([PetSection].self)
        testSubject
            .sections
            .bind(to: sectionsObserver)
            .disposed(by: disposeBag)
        
        let loadingStateObserver = scheduler.createObserver(LoadingState.self)
        testSubject
            .loadingState
            .bind(to: loadingStateObserver)
            .disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.error(10, TestError.itHappened)])
            .bind(to: petService.pets)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(sectionsObserver.events, [.next(0, [])])
        XCTAssertEqual(loadingStateObserver.events, [.next(0, .loading),
                                                     .next(10, .error(message: "itHappened"))])
    }
    
    func testNavigation() throws {
        let navigationObserver = scheduler.createObserver(Navigation.Source.self)
        navigator
            .sourceEvent
            .bind(to: navigationObserver)
            .disposed(by: disposeBag)
        
        let comodorePet = Pet(id: 0,
                              name: "Comodore",
                              species: "Computer",
                              size: .medium,
                              status: .adopted,
                              distance: 15)
        
        let plasticPet = Pet(id: 1,
                             name: "Plastic",
                             species: "Recyclable",
                             size: .small,
                             status: .found,
                             distance: 1000)
        
        let petre = Pet(id: 2,
                        name: "Petre",
                        species: "Fabulist si epigramist",
                        size: .large,
                        status: .adoptable)
        
        scheduler
            .createColdObservable([.next(10, [comodorePet, plasticPet, petre])])
            .bind(to: petService.pets)
            .disposed(by: disposeBag)
        
        let comodorePetItem = PetItem(pet: comodorePet,
                                      distanceFormatter: NumberFormatter(),
                                      photo: .never())
        
        scheduler
            .createColdObservable([.next(20, comodorePetItem)])
            .bind(to: testSubject.itemSelected)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(navigationObserver.events,
                       [.next(20, .petList(event: .showDetails(comodorePetItem)))])
    }
}

enum TestError: Error, Equatable {
    case itHappened
}

class MockPetAPIService: PetAPIService {
    let pets = PublishSubject<[Pet]>()
    
    func getPets(location: Location?) -> RxSwift.Observable<[Pet]> {
        return pets.asObservable()
    }
}

class MockMediaService: MediaSevice {
    func getPhoto(url: URL?) -> RxSwift.Observable<UIImage> {
        return .never()
    }
}

class MockNavigator: Navigator {
    let sourceEvent = RxRelay.PublishRelay<Navigation.Source>()
    let transition = RxRelay.PublishRelay<Navigation.Transition>()
    let destinationData = RxRelay.ReplayRelay<Navigation.Destination>.create(bufferSize: 1)
}
