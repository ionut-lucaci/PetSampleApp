//
//  Sectionable.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation
import RxDataSources

protocol Sectionable {
    associatedtype Section : Equatable
    var sectionedBy: Section { get }
}

extension Array where Element: Sectionable {
    func sectioned() -> [SectionModel<Element.Section, Element>] {
        var sections = [SectionModel<Element.Section, Element>]()
        
        for element in self {
            let sectionedBy = element.sectionedBy

            if var last = sections.last, sectionedBy == last.model {
                last.items.append(element)
                sections[sections.count - 1] = last
            } else {
                sections.append(SectionModel(model: sectionedBy, items: [element]))
            }
        }
    
        return sections
    }
}
