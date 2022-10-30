//
//  Observable.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation
import RxSwift

extension ObservableType where Element: Sequence {
    func mapElements<Result>(_ transform: @escaping (Element.Element) throws -> Result) -> Observable<[Result]> {
        return map { try $0.map { try transform($0) } }
    }
}
