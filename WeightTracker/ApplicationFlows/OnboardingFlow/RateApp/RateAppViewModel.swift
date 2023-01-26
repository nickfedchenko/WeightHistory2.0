//
//  RateAppViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import ApphudSDK
import UIKit

final class RateAppViewModel {
     
    // MARK: - Property list
    var bottomRateButtonConstraint: CGFloat = 0
    var topRateImageConstraint: CGFloat = 0
    var topCloseButtonConstraint: CGFloat = 0
    var topDescriptionConstraint: CGFloat = 0
    
    var reviews: [ReviewModel] = []
    
    // MARK: - Init
    init() {
        calculateConstraints()
        makeReviews()
    }
    
    // MARK: - CALCULATE CONSTRAINTS
    private func calculateConstraints() {
        if UIDevice.screenType == .less {
            bottomRateButtonConstraint = 30
            topRateImageConstraint = 40
            topCloseButtonConstraint = 35
            topDescriptionConstraint = 20
        } else {
            bottomRateButtonConstraint = 90
            topRateImageConstraint = 69
            topCloseButtonConstraint = 64
            topDescriptionConstraint = 33
        }
    }
    
    // MARK: - MAKE REVIEWS
    private func makeReviews() {
        reviews = [
            .init(reviewText: R.string.localizable.onboardingRateReviewMaria(), userName: "Cold Maria", userPhoto: R.image.photoWoman1() ?? UIImage()),
            .init(reviewText: R.string.localizable.onboardingRateReviewWilliamsster(), userName: "Williamsster", userPhoto: R.image.photoMan() ?? UIImage()),
            .init(reviewText: R.string.localizable.onboardingRateReviewAnabel(), userName: "Anabel@WhiteMagic", userPhoto: R.image.photoWoman2() ?? UIImage())
        ]
    }
    
    // MARK: - CHECK SUBSCRIPTION
    func isSubscriptionActive() -> Bool {
        Apphud.hasActiveSubscription()
    }
}

