//
//  AppDelegate.swift
//  Shopping List
//
//  Created by Pavel Moroz on 18.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

public let myDefaults = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Получение текущего значения sessionCount из UserDefaults
        var sessionCount = myDefaults.integer(forKey: "sessionCount")
        sessionCount += 1
        myDefaults.set(sessionCount, forKey: "sessionCount")
        
        print("Session \(sessionCount)")
        
        //на 20й раз сбрасываем условия чтоб снова предложить оценить
        if myDefaults.bool(forKey: "ratingLaterTimer") == true && myDefaults.integer(forKey: "sessionCount") == 30 {
            myDefaults.set(0, forKey: "sessionCount")
            myDefaults.set(false, forKey: "ratingLaterTimer")
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
