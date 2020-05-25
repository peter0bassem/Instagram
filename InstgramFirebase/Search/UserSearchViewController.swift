//
//  UserSearchViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class UserSearchViewController: UICollectionViewController {
    
    lazy var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Enter username"
        searchBar.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        searchBar.delegate = self
        return searchBar
    }()
    
    let cellId = "cellId"
    var users = [User]()
    var filteredUsers = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leadingAnchor, bottom: navBar?.bottomAnchor, right: navBar?.trailingAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView.register(UserSearchCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
    
    private func fetchUsers() {
        let reference = Database.database().reference().child("users")
        reference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            guard let dictionaries = dataSnapshot.value as? [String:Any] else { return }
            
            dictionaries.forEach { (key, value) in
                
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as? [String:Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            }
            
            self.users.sort { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            }
            
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        }) { (error) in
            print("failed to fetch users:", error)
        }
    }
}

extension UserSearchViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCollectionViewCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        print(user.username)
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.userId = user.uid
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
}

extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

extension UserSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView.reloadData()
    }
}
