//
//  Comment.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/15/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation

struct Comment {
    let user: User
    
    let text: String
    let uid: String
    
    init(user: User, dicitionary: [String:Any]) {
        text = dicitionary["text"] as? String ?? ""
        uid = dicitionary["uid"] as? String ?? ""
        self.user = user
    }
}
