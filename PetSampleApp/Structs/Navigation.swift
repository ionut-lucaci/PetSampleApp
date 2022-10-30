//
//  Navigation.swift
//  PetSample
//
//  Created by Ionut Lucaci on 29.10.2022.
//

import Foundation

struct Navigation {
    enum Source: Equatable {
        case petList(event: PetListEvent)
        
        enum PetListEvent: Equatable {
            case showDetails(_: PetItem)
        }
    }
    
    enum Destination: Equatable {
        case petDetails(data: PetItem)
    }
    
    enum NodeId: String, Equatable {
        case PetsViewController
        case PetDetailsViewController
    }
    
    struct Transition: Equatable {
        let source: NodeId
        let style: Style
        
        enum Style: Equatable {
            case segue(id: SegueId)
            case dismiss(animated: Bool)
            case pop(animated: Bool)
            
            enum SegueId: String, Equatable {
                case showPetDetails
            }
        }
    }
}
