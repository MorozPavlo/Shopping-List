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
        
        // Створюємо SwiftUI екран
        let contentView = MainView()
        
        // Створюємо UIWindow
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            // Встановлюємо SwiftUI екран як rootViewController
            window.rootViewController = UIHostingController(rootView: contentView)
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Shopping_List")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
