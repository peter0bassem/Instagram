//
//  FirebaseUtils.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        print("fetching user with uid:", uid)
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let userDictionary = dataSnapshot.value as? [String:Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("failed to fetch user for posts:", error)
        }
    }
}
