//
//  CommentInputAccessoryView.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/22/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: class {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment"
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmitButtonPress(_:)), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 12, width: 50, height: 0)
        
        addSubview(commentTextField)
        commentTextField.anchor(top: topAnchor, left: leadingAnchor, bottom: bottomAnchor, right: submitButton.leadingAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeparatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leadingAnchor, bottom: nil, right: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    func clearCommentTextField() {
        commentTextField.text = nil
    }
    
    @objc func handleSubmitButtonPress(_ sender: UIButton) {
        guard let commentText = commentTextField.text else { return }
        delegate?.didSubmit(for: commentText)
    }
}
