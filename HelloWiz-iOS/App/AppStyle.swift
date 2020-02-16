//
//  AppStyle.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-02-14.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit

class AppStyle {
    static func initialize() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBarAppearance.barTintColor = UIColor.wizPurple

        UIBarButtonItem.appearance(whenContainedInInstancesOf:
            [UISearchBar.self]).setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UITabBar.appearance().tintColor = UIColor.wizPurple
    }
}
