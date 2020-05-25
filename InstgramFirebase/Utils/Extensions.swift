//
//  Extensions.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/8/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leadingAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            trailingAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Date {
  func timeAgo() -> String {
    let secondsAgo = Int(Date().timeIntervalSince(self))
    
    let minute = 60
    let hour = minute * 60
    let day = 24 * hour
    let week = 7 * day
    let month = 30 * day
    
    let quotient: Int
    let unit: String
    
    if secondsAgo < 5 {
      quotient = 0
      unit = "Just now"
    } else if secondsAgo < minute {
      quotient = secondsAgo
      if quotient > 1 {
        unit = "seconds"
      } else {
        unit = "second"
      }
    } else if secondsAgo < hour {
      quotient = secondsAgo / minute
      if quotient > 1 {
        unit = "minutes"
      } else {
        unit = "minute"
      }
    } else if secondsAgo < day {
      quotient = secondsAgo / hour
      if quotient > 1 {
        unit = "hours"
      } else {
        unit = "hour"
      }
    } else if secondsAgo < week {
      quotient = secondsAgo / day
      if quotient > 1 {
        unit = "days"
      } else {
        unit = "day"
      }
    } else if secondsAgo < month {
      quotient = secondsAgo / week
      if quotient > 1 {
        unit = "weeks"
      } else {
        unit = "week"
      }
    } else {
      quotient = 0
      let formatter = DateFormatter()
      formatter.dateFormat = "ddmmmmyyyy"
      unit = formatter.string(from: self)
    }
    
    let quotientStr = quotient > 0 ? "\(quotient) " : ""
    let postfix = quotientStr.isEmpty ? "" : " ago"
    let result = quotientStr + unit + postfix
    return result
  }
}
