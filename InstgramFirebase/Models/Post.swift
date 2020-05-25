//
//  Post.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/9/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation

struct Post {
    var id: String?
    
    let user: User
    let imageUrl: String
    let caption: String
    let creationDate: Date
    
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String:Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.user = user
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
