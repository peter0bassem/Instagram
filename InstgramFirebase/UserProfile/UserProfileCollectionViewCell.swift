//
//  UserProfileCollectionViewCell.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/9/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class UserProfileCollectionViewCell: UICollectionViewCell {
    
    let imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            
            imageView.loadImage(urlString: imageUrl)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leadingAnchor, bottom: bottomAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
