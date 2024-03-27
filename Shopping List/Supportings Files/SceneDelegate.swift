//
//  SceneDelegate.swift
//  Shopping List
//
//  Created by Pavel Moroz on 18.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                   
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewController = MainView()
        window?.rootViewController = UIHostingController(rootView: viewController)
        window?.makeKeyAndVisible()
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
    }
}

