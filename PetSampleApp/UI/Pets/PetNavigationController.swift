//
//  NavigationController.swift
//  PetSample
//
//  Created by Ionut Lucaci on 29.10.2022.
//

import UIKit
import RxSwift
import RxCocoa

protocol NavigationNode: UIViewController {
    var navigator: Navigator { get }
}

extension NavigationNode {
    var navigator: Navigator {
        let petNav = (navigationController as? PetNavigationController)
        assert(petNav != nil, "Navigation miconfigured: Navigation controller is of unexpected class.")
        
        return (petNav?.navigator ?? PetSampleNavigator())
    }
}


class PetNavigationController: UINavigationController {

    lazy var navigator = PetSampleNavigator()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigator
            .transition
            .subscribe(onNext: { [weak self] trans in self?.handleTransition(transition: trans) })
            .disposed(by: navigator.disposeBag)
    }
    
    func handleTransition(transition: Navigation.Transition) {
        switch transition.style {
        case .segue(let segueId):
            guard let source = viewControllers.first(where: { $0.restorationIdentifier == transition.source.rawValue }) else {
                assertionFailure("Navigation miconfigured: Searching for yet uninstantiated view controller.")
                return
            }

            source.performSegue(withIdentifier: segueId.rawValue,
                                sender: navigator)
        case .pop(let animated):
            popViewController(animated: animated)
        case .dismiss(let animated):
            dismiss(animated: animated)
        }
    }
}
