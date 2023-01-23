 //
//  AppDelegate.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import Amplitude
import ApphudSDK
import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var vc = UIViewController()
        if UserSettingsService.shared.isFirstLaunch() {
            vc = StartScreenViewController()
        } else {
            vc = MainScreenViewController()
        }
        let window = UIWindow()
        let navVC = UINavigationController()
        navVC.setViewControllers([vc], animated: true)
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}
