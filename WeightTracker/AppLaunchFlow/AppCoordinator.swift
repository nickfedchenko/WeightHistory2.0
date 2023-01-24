//
//  AppCoordinator.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import Amplitude
import ApphudSDK
import UIKit

final class AppCoordinator {
    
    // MARK: - Property list
    private let navigationController = UINavigationController()
    private let userSettingsService = UserSettingsService.shared
    private let window: UIWindow
    
    // MARK: - Init
    init(window: UIWindow) {
        self.window = window
    }
        
    // MARK: - App start method
    func start() {
        showOnboarding()
    }
    
    // MARK: - Preparing screen
    private func showOnboarding() {
        let startScreen = StartScreenViewController()
        navigationController.setViewControllers([startScreen], animated: true)
        window.rootViewController = navigationController
    }
    
//    private func showMainScreen() {
//        let mainScreen = MainScreenViewController()
//        navigationController.setViewControllers([mainScreen], animated: true)
//        window.rootViewController = navigationController
//    }
    
    // MARK: - Configure third party libraries
    private func configureApphudSDK() {
        Apphud.start(apiKey: "ОБНОВИТЬ ИЗ ТРЕЛЛО")
    }
    
    private func configureAmplitude() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("ОБНОВИТЬ ИЗ ТРЕЛЛО", userId: Apphud.userID())
        Amplitude.instance().logEvent("app_start")
    }
}
