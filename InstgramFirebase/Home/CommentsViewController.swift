//
//  CommentsViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/15/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UICollectionViewController {
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    var post: Post?
    let cellId = "cellId"
    var comments = [Comment]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func fetchComments() {
        guard let postId = post?.id else { return }
        let reference = Database.database().reference().child("comments").child(postId)
        reference.observe(.childAdded, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String:Any] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid) { (user) in
                
                let comment = Comment(user: user, dicitionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }) { (error) in
            print("failed to observe comments:", error)
        }
    }
    
    var _inputAccessoryView: UIView!
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
        
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
//    @objc private func handleSubmitButtonPress(_ sender: UIButton) {
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        print(commentTextField.text ?? "")
//        
//        print("post id:", post?.id ?? "")
//        
//        let postId = post?.id ?? ""
//        let values: [String:Any] = ["text": commentTextField.text ?? "", "creationData": Date().timeIntervalSince1970, "uid": uid]
//        
//        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, databaseReference) in
//            if let error = error {
//                print("failed to insert comment:", error)
//                return
//            }
//            print("successfully inserted comment.")
//        }
//    }
}

extension CommentsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCollectionViewCell
        cell.comment = comments[indexPath.item]
        return cell
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCollectionViewCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max((40 + 8 + 8), estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CommentsViewController: CommentInputAccessoryViewDelegate {
    
    func didSubmit(for comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        print("post id:", post?.id ?? "")
        
        let postId = post?.id ?? ""
        let values: [String:Any] = ["text": comment, "creationData": Date().timeIntervalSince1970, "uid": uid]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, databaseReference) in
            if let error = error {
                print("failed to insert comment:", error)
                return
            }
            print("successfully inserted comment.")
            
            self.containerView.clearCommentTextField()
        }
    }
}
