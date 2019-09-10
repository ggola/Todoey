//
//  AppDelegate.swift
//  Todoey
//
//  Created by Giulio Gola on 05/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let realmLocation = Realm.Configuration.defaultConfiguration.fileURL
        print(realmLocation!)
        
        // Create a Realm instance
        do {
            _ = try Realm()
        } catch {
            print(error.localizedDescription)
        }
        return true
    }
}
