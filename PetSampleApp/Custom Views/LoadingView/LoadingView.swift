//
//  LoadingView.swift
//  PetSample
//
//  Created by Ionut Lucaci on 26.10.2022.
//

import UIKit
import RxSwift

class LoadingView: UIView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setup(loadingState: LoadingState) {
        activityIndicator.isHidden = !loadingState.hasActivity
        stateLabel.text = loadingState.state
        messageLabel.text = loadingState.message
    }
}

extension Reactive where Base: LoadingView {
    var loadingState: Binder<LoadingState> {
        return Binder.init(self.base, binding: { view, state in
            view.setup(loadingState: state)
        })
    }
}
