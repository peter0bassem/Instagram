//
//  SharePhtotoViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/9/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class SharePhtotoViewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textView: UITextView = {
      let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShareBarButtonPress(_:)))
        
        setupImageAndTextViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, bottom: nil, right: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leadingAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.trailingAnchor, bottom: containerView.bottomAnchor, right: containerView.trailingAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    private func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostReference = Database.database().reference().child("posts").child(uid)
        let reference = userPostReference.childByAutoId()
        
        let values: [String:Any] = ["imageUrl": imageUrl, "caption": textView.text ?? "", "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970]
        reference.updateChildValues(values) { (error, databaseReference) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to save post to db:", error)
                return
            }
            print("successfully saved post to db")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhtotoViewController.updateFeedNotificationName, object: nil)
        }
    }
    
    @objc private func handleShareBarButtonPress(_ sender: UIBarButtonItem) {
        guard let image = selectedImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.8) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = UUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(uploadData, metadata: metadata) { (storageMetaData, error) in
            if let error = error {
                print("failed to upload post image:", error)
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("failed to get profile image url:", error)
                    return
                }
                guard let imageUrl = url?.absoluteString else { return }
                print("Successfully uploaded post image", imageUrl)
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            }
        }
    }
}
