//
//  CustomPageControl.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

final class CustomPageControl: UIPageControl {

    //MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    //MARK: - Private methods
    private func configure() {
        numberOfPages = 5
        tintColor = .clear
        pageIndicatorTintColor = .onboardingPageControlSecondary
        currentPageIndicatorTintColor = .onboardingPageControlCurrent
    }
}
