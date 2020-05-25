//
//  UserSearchCollectionViewCell.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class UserSearchCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    var user: User? {
        didSet {
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, left: leadingAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 50 / 2
        
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.trailingAnchor, bottom: bottomAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: usernameLabel.leadingAnchor, bottom: bottomAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
