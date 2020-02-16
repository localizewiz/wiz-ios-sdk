//
//  AppDelegate.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit
import LocalizeWiz

var wiz = Wiz.sharedInstance

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let testApiKey = "wiz_3e1457d5f61c76c41c769f90a76f7888"
        let testProjectId = "99340930464613842"

        let apiKey = "wiz_c44cbfd8d665b9b6db7c049fae4d1c9d"
        let projectId = "16517129557771591"

        wiz.configure(apiKey: testApiKey, projectId: testProjectId, language: "en")
        AppStyle.initialize()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

