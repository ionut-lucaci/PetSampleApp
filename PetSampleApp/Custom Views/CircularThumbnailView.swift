//
//  PetThumbView.swift
//  PetSample
//
//  Created by Ionut Lucaci on 29.10.2022.
//

import UIKit

class CircularThumbnailView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = (frame.width/2)
    }
}
