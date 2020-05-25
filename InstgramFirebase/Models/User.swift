//
//  User.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
