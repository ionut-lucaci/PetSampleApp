//
//  ImageCacheService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 27.10.2022.
//

import Foundation
import RxSwift

protocol ImageCacheService {
    // in
    func cache(_ image: UIImage, for url: URL)
    
    // out
    func image(for: URL) -> UIImage?
}

class MemoryImageCacheService: ImageCacheService {
    // MARK: - State
    private let cache = NSCache<NSURL, UIImage>()
    
    // MARK: - Public methods
    func cache(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
}
