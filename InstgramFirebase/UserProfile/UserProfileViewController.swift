//
//  UserProfileViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/8/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UICollectionViewController {
    
    var user: User?
    var userId: String? 
    let cellId = "cellId"
    let homePostCell = "homePostCell"
    var posts = [Post]()
    var isGridView = true
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: homePostCell)
        
        setupLogOutButton()
        fetchUser()
//        fetchOrderedPosts()
    }
    
    private func fetchUser() {
        
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            
            self.collectionView.reloadData()
            self.paginatePosts()
        }
    }
    
    private func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOutBarButtonPress(_:)))
    }
    
    private func fetchOrderedPosts() {
        guard let uid = user?.uid else { return  }
        let reference = Database.database().reference().child("posts").child(uid)
        
        reference.queryOrdered(byChild: "creationData").observe(.childAdded, with: { (dataSnapshot) in
            guard let dictionary = dataSnapshot.value as? [String:Any] else { return }
            
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
//            self.posts.append(post)
            
            self.collectionView.reloadData()
            
        }) { (error) in
            print("failed to fetch ordered posts:", error)
        }
    }
    
    private func paginatePosts() {
        print("start paging for more posts")
        
        guard let uid = user?.uid else { return }
        let reference = Database.database().reference().child("posts").child(uid)
        
//        var query = reference.queryOrderedByKey()
        
        var query = reference.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard var allObjects = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else { return }
            
            allObjects.forEach { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
                
//                print(snapshot.key)
            }
            
            self.posts.forEach { print($0.id ?? "") }
            
            self.collectionView.reloadData()
            
            
        }) { (error) in
            print("Failed to paginate for posts:", error)
        }
    }
    
    @objc private func handleLogOutBarButtonPress(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                
                let loginViewController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginViewController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch let error {
                print("failed to sign out:", error)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension UserProfileViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCollectionViewCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCell, for: indexPath) as! HomePostCollectionViewCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 //userprofileimageview
            height += view.frame.width
            height += 50
            height += 60
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension UserProfileViewController: UserProfileHeaderDelegate {
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
}
