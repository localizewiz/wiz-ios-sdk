//
//  UIColor.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-02-14.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit

extension UIColor {


    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }

    static let wizPurple = UIColor(rgb: 0x311b92)

}
