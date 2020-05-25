//
//  CustomImageView.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/10/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUserToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUserToLoadImage = urlString
        
        self.image = nil
        
        if let cahcedImage = imageCache[urlString] {
            self.image = cahcedImage
            return
        }
        
        guard let url = URL(string: urlString ) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("failed to fetch post image:", error)
                return
            }
            
            if url.absoluteString != self.lastURLUserToLoadImage {
                return
            }
            
            guard let data = data else { return }
            let image = UIImage(data: data)
            
            imageCache[url.absoluteString] = image
            
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }
}
