//
//  HomeViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UICollectionViewController {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeedNotification(_:)), name: SharePhtotoViewController.updateFeedNotificationName, object: nil)
        
        collectionView.backgroundColor = .white
        
        collectionView.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshCollectionView(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems()
        
        fetchAllPosts()
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCameraBarButtonPress(_:)))
    }
    
    private func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    private func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user)
        }
    }
    
    private func fetchPostsWithUser(_ user: User) {
        print("fetching posts with user:", user.uid)
        
        let reference = Database.database().reference().child("posts").child(user.uid)
        reference.observeSingleEvent(of: .value , with: { (dataSnapshot) in
            
            self.collectionView.refreshControl?.endRefreshing()
            
            guard let dictionaries = dataSnapshot.value as? [String:Any] else { return }
            
            dictionaries.forEach { (key, value) in
                
                guard let dictionary = value as? [String:Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    if let value = dataSnapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort { (post1, post2) -> Bool in
                        return post1.creationDate.compare(post2.creationDate) == .orderedDescending
                    }
                    self.collectionView.reloadData()
                }) { (error) in
                    print("failed to fetch like info for post:", error)
                }
            }
        }) { (error) in
            print("failed to fetch user posts:", error)
        }
    }
    
    private func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let userIdsDictionary = dataSnapshot.value as? [String:Any] else { return }
            
            userIdsDictionary.forEach { (key, value) in
                Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostsWithUser(user)
                }
            }
            
        }) { (error) in
            print("failed to fetch following user ids:", error)
        }
    }
    
    @objc private func handleCameraBarButtonPress(_ sener: UIBarButtonItem) {
        print("show camera")
        
        let cameraViewController = CameraViewController()
        cameraViewController.modalPresentationStyle = .fullScreen
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @objc private func handleRefreshCollectionView(_ selector: UIRefreshControl) {
        print("handling refresh...")
        posts.removeAll()
        fetchAllPosts()
    }
    
    @objc private func handleUpdateFeedNotification(_ sender: NotificationCenter) {
        posts.removeAll()
        fetchAllPosts()
    }
}

extension HomeViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCollectionViewCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 //userprofileimageview
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
}

extension HomeViewController: HomePostCellDelegate {
    
    func didLike(for cell: HomePostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = posts[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values: [String:Any] = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (error, _) in
            if let error = error {
                print("failed to like post:", error)
                return
            }
            print("successfully liked post")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func didTapComment(post: Post) {
        print("your message coming from homeviewcontroller")
        let commentsViewController = CommentsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsViewController.post = post
        navigationController?.pushViewController(commentsViewController, animated: true)
    }
}
