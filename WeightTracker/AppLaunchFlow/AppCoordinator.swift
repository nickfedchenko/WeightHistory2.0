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
        
    // MARK: - APPLICATION START
    func start() {
        if userSettingsService.isOnboardingPassed() {
            showMainStage()
        } else {
            showOnboarding()
        }
    }
    
    // MARK: - PREPARING SCREENS
    private func showOnboarding() {
        let startScreen = StartScreenViewController()
        navigationController.setViewControllers([startScreen], animated: true)
        window.rootViewController = navigationController
    }
    
    private func showMainStage() {
        let mainStage = MainStageViewController()
        navigationController.setViewControllers([mainStage], animated: true)
        window.rootViewController = navigationController
    }
    
    // MARK: - CONFIGURE THIRD-PARTY LIBRABRIES
    private func configureApphudSDK() {
        Apphud.start(apiKey: "app_2GRrpGPdhK66w4EbTcbJwTqknCGpmu")
    }
    
    private func configureAmplitude() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("ad65a7c8175c1f57f7d5a4eda911a49e", userId: Apphud.userID())
        Amplitude.instance().logEvent("app_start")
    }
}
