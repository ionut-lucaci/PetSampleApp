//
//  PetThumbnailDisplaying.swift
//  PetSample
//
//  Created by Ionut Lucaci on 29.10.2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol PetThumbnailDisplaying: AnyObject {
    var photoView: CircularThumbnailView! { get }
    var emojiLabel: UILabel! { get }
    var recycleBin: DisposeBag { get set }
}

extension PetThumbnailDisplaying {
    func resetThumbnailState() {
        recycleBin = DisposeBag()     
    }
    
    func bind(photo: Observable<UIImage>, emoji: String) {
        emojiLabel.text = emoji
        emojiLabel.isHidden = false
        photoView.image = nil
        
        photo
            .bind(to: photoView.rx.image)
            .disposed(by: recycleBin)
        
        photo
            .mapTo(true)
            .bind(to: emojiLabel.rx.isHidden)
            .disposed(by: recycleBin)
    }
}
