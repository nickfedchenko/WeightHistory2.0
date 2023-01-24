//
//  OnboardingViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit
import CoreData

final class OnboardingViewModel {
    
    //MARK: - Property list
    private let dbService = CoreDataService.shared
    
    var isUserMale: Bool {
        get {
            UserSettingsService.shared.isUserMale
        }
        set {
            UserSettingsService.shared.isUserMale = newValue
        }
    }
    
    // MARK: - Init
    init() {}
    
    //MARK: - Constarints properties
    var topScreenImageViewConstarint: CGFloat {
        UIDevice.screenType == .less ? 60 : 100
    }
    
    var bottomDatePickerConstraint: CGFloat {
        UIDevice.screenType == .less ? -20 : -50
    }
    
    //MARK: - Saving user data
    func saveUserGender(with gender: Int16) {
        dbService.saveUserGender(value: gender)
    }
    
    func saveUserHeight(with height: String) {
        guard let heightMeas = Double(height) else { return }
        dbService.saveUserHeight(value: heightMeas)
    }
    
    func saveUserBirthday(date: Date) {
        dbService.saveUserBirthday(date: date)
    }
    
    func saveUserStartWeight(with weight: String) {
        guard let weightMeas = Double(weight) else { return }
        dbService.saveUserStartWeight(value: weightMeas)
    }
    
    func saveUserGoalWeight(with weight: String) {
        guard let weightMeas = Double(weight) else { return }
        dbService.saveUserGoalWeight(value: weightMeas)
    }
    
    func saveUserGoal(with goal: String) {
        dbService.saveUserGoal(answer: goal)
    }
    
    func saveUserWeightFrequency(with answer: String) {
        dbService.saveUserWeightFrequency(answer: answer)
    }
}

