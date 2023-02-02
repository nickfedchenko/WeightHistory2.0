//
//  SettingsViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import Foundation

final class SettingsViewModel {
    
    // MARK: - Property list
    private let userSettingsService = UserSettingsService.shared
    private let dbService = CoreDataService.shared
    private let healthKitService = HealthKitService.shared
    
    var settingsData: [[SettingsCellModel]] = []
    var settingsTableSectionTitles: [String] = []

    var isAppleHealthOn = false {
        willSet {
            changeIsAppleHealthOn(value: newValue)
        }
    }
    var isHapticFeedbackOn = true {
        willSet {
            changeIsHapticFeedbackOn(value: newValue)
        }
    }
    
    var userGender: String = ""
    var userHeight: Double = 0
    var userStartWeight: Double = 0
    var userGoalWeight: Double = 0
    var userLengthUnit: String = ""
    var userWeightUnit: String = ""
    var userGoal: String = ""
    var userBirthday: Date = Date()
    var userAge: Int = 0
    var measurementStringResult = ""
    private var measurementResult: Double = 0
    
    // MARK: - Configuration
    func configure() {
        setSectionTitles()
        getUserUnits()
        getUserHeight()
        getUserStartInfo()
        getUserAge()
        getSettingsSwitchesState()
        updateUserSettingsData()
    }
    
    // MARK: - Public methods
    func isUserMale() -> Bool {
        var isUserMale = false
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                let gender = success.userGender
                gender == 1 ? (isUserMale = true) : (isUserMale = false)
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        return isUserMale
    }
    
    func requestHealthDataPermission(completion: @escaping (Bool) -> Void) {
        healthKitService.requestPermission(completion: completion)
    }
    
    func saveUserNewGoalWeight() {
        getMeasurementResult()
        dbService.saveUserGoalWeight(value: measurementResult)
    }
    
    func saveUserNewHeight() {
        getMeasurementResult()
        dbService.saveUserHeight(value: measurementResult)
    }
    
    func saveUserNewStartingWeight() {
        getMeasurementResult()
        dbService.saveUserStartWeight(value: measurementResult)
    }
    
    func saveUserNewAge() {
        getMeasurementResult()
        let date = Calendar.current.date(byAdding: .year, value: -(Int(measurementResult)), to: Date()) ?? Date()
        dbService.saveUserBirthday(date: date)
    }
    
    func saveUserData(selectorType: SettingsSelectorType, value: String) {
        switch selectorType {
        case .userGender:
            if value == R.string.localizable.onboardingGenderMale() {
                dbService.saveUserGender(value: 1)
                userSettingsService.isUserMale = true
            } else {
                dbService.saveUserGender(value: 0)
                userSettingsService.isUserMale = false
            }
        case .units:
            if value.contains(R.string.localizable.unitsKg()) {
                userSettingsService.saveUserLengthUnit(lenght: .cm)
                userSettingsService.saveUserWeighthUnit(weight: .kg)
                userSettingsService.isImperial = false
            } else {
                userSettingsService.saveUserLengthUnit(lenght: .ft)
                userSettingsService.saveUserWeighthUnit(weight: .lbs)
                userSettingsService.isImperial = true
            }
        case .userGoal:
            dbService.saveUserGoal(answer: value)
        }
    }
    
    // MARK: - Private methods
    private func setSectionTitles() {
        settingsTableSectionTitles = [
            R.string.localizable.settingsProfileSectionTitle(),
            R.string.localizable.settingsAppSettingsSectionTitle()
        ]
    }
    
    private func getUserUnits() {
        userLengthUnit = userSettingsService.getUserLenghtUnit()
        userWeightUnit = userSettingsService.getUserWeighthUnit()
    }
    
    private func getUserHeight() {
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                userHeight = success.userHeight
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }

    private func getUserStartInfo() {
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                userGender = success.userGenderString
                userStartWeight = roundTen(success.userStartWeight)
                userGoalWeight = roundTen(success.userGoalWeight)
                userGoal = success.userGoal ?? R.string.localizable.onboardingGoalLoseWeight()
                userBirthday = success.userBirthday ?? Date()
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
    
    private func getUserAge() {
        let ageComponents = Calendar.current.dateComponents([.year], from: userBirthday, to: Date())
        userAge = ageComponents.year ?? 18
    }
    
    private func updateUserSettingsData() {
        settingsData = []
        let height = "\(Int(userHeight.actualLengthValue())) " + userLengthUnit
        let startWeight = "\(String(format: "%.1f", userStartWeight.actualWeightValue())) " + userWeightUnit
        let goalWeight = "\(String(format: "%.1f", userGoalWeight.actualWeightValue())) " + userWeightUnit
        let age = "\(userAge)"
        let units = userWeightUnit + " / " + userLengthUnit
        
        let fisrtSection: [SettingsCellModel] = [
            .init(title: R.string.localizable.settingsGender(), type: .withSelector, value: userGender),
            .init(title: R.string.localizable.settingsHeight(), type: .withTextField, value: height),
            .init(title: R.string.localizable.settingsStartingWeight(), type: .withTextField, value: startWeight),
            .init(title: R.string.localizable.settingsWeightGoal(), type: .withTextField, value: goalWeight),
            .init(title: R.string.localizable.onboardingGoalYourGoal(), type: .withSelector, value: userGoal),
            .init(title: R.string.localizable.settingsAge(), type: .withTextField, value: age)
        ]
        
        let secondSection: [SettingsCellModel] = [
            .init(title: R.string.localizable.settingsUnits(), type: .withSelector, value: units),
            .init(title: R.string.localizable.settingsHealthSync(), type: .withSwith, value: ""),
            .init(title: R.string.localizable.settingsHaptic(), type: .withSwith, value: ""),
            .init(title: R.string.localizable.settingsDoYouLikeApp(), type: .withTouchEvent, value: ""),
            .init(title: R.string.localizable.settingsSuggestAFeature(), type: .withTouchEvent, value: ""),
            .init(title: R.string.localizable.settingsContactUs(), type: .withTouchEvent, value: ""),
            .init(title: R.string.localizable.settingsReccomended(), type: .withTouchEvent, value: "")
        ]
        settingsData.append(fisrtSection)
        settingsData.append(secondSection)
    }
    
    private func getMeasurementResult() {
        measurementResult = Double(measurementStringResult.replaceDot()) ?? 0
    }
    
    // MARK: - VALIDATION
    func isMeasurementResultValid(for type: SettingsType) -> Validation {
        
        if measurementStringResult.last == "." &&  measurementStringResult.last == "," {
            return .incorrectData
        } else if measurementStringResult == "" || measurementStringResult == " " {
            return .empty
        }
        
        guard let result = Double(measurementStringResult.replaceDot()) else { return .incorrectData }


        if type == .goalWeight || type == .startWeight {
            let unit = userSettingsService.getUserWeighthUnit()
            if unit == R.string.localizable.unitsKg() {
                if result > 2 && result < 250 {
                    return .normal
                } else {
                    return .outOfRange
                }
            } else {
                if result > 4 && result < 550 {
                    return .normal
                } else {
                    return .outOfRange
                }
            }
            
        } else if type == .length {
            let unit = userSettingsService.getUserLenghtUnit()
            if unit == R.string.localizable.unitsCm() {
                if result > 10 && result < 250 {
                    return .normal
                } else {
                    return .outOfRange
                }
            } else {
                if result > 0.3 && result < 8.2 {
                    return .normal
                } else {
                    return .outOfRange
                }
            }
        } else {
            if result >= 0 && result < 120 {
                return .normal
            } else {
                return .incorrectData
            }
        }
    }
    
    // MARK: - USER SETTING SERVICE METHODS
    private func getSettingsSwitchesState() {
        isAppleHealthOn = userSettingsService.getIsAppleHealthOn()
        isHapticFeedbackOn = userSettingsService.getIsHapticFeedbackOn()
    }
    
    private func changeIsAppleHealthOn(value: Bool) {
        userSettingsService.setIsAppleHealthOn(value: value)
    }
    
    private func changeIsHapticFeedbackOn(value: Bool) {
        userSettingsService.setIsHapticFeedbackOn(value: value)
    }
}
