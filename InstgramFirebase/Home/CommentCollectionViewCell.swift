//
//  CommentCollectionViewCell.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/15/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
//        textView.numberOfLines = 0
        textView.isScrollEnabled = false
        return textView
    }()
    
    var comment: Comment? {
        didSet {
            guard let profileImageUrl = comment?.user.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            
            guard let username = comment?.user.username else { return }
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " " + (comment?.text ?? ""), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
            
            textView.attributedText = attributedText
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leadingAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
//        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.trailingAnchor, bottom: bottomAnchor, right: trailingAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
