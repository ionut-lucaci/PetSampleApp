//
//  UIView.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

extension UIView {
    static func loadFlomNib(named name: String? = nil) -> Self? {
        let nibName = name ?? String(describing: Self.self)
        let result = Bundle
            .main
            .loadNibNamed(nibName, owner: self, options: nil)?
            .first
        
        return (result as? Self)
    }
}


extension Reactive where Base: UIView {
    var toast: Binder<String> {
        return Binder.init(self.base, binding: { (view, toastMessage) in
            view.makeToast(toastMessage)
        })
    }
}
