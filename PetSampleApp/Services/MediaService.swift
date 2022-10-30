//
//  MediaService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import UIKit

// MARK: - Interface

protocol MediaSevice {
    func getPhoto(url: URL?) -> Observable<UIImage>
}

// MARK: - Implementation

class CachedMediaService: MediaSevice {
    // MARK: - Dependencies
    private let net: NetworkService
    private let cache: ImageCacheService
    
    // MARK: - Public methods
    init(networkService: NetworkService, imageCacheService: ImageCacheService) {
        net = networkService
        cache = imageCacheService
    }
    
    func getPhoto(url: URL?) -> Observable<UIImage> {
        guard let url = url else { return .never() }
        
        return Observable<UIImage?>
            .create { [weak self] obs in
                obs.onNext(self?.cache.image(for: url))
                
                return Disposables.create()
            }
            .flatMap { [weak self] img in
                if let img = img {
                    return Observable.just(img)
                } else {
                    return self?
                        .net
                        .performDataRequest(endpoint: .photo(url: url))
                        .catch { _ in .never() }
                        .map { UIImage(data: $0) }
                        .unwrap()
                        .observe(on: MainScheduler.asyncInstance)
                        .do(onNext: { [weak self] img in self?.cache.cache(img, for: url) })
                        .share(replay: 1) ?? .never()
                }
            }
            .share(replay: 1)
    }
}


