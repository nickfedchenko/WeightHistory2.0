 //
//  AppDelegate.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        coordinator = AppCoordinator(window: window)
        coordinator?.start()
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}
