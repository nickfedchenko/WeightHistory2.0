//
//  BMIViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import Foundation

final class BMIViewModel {
    
    // MARK: - Property list
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    private let facade: DataProviderServiceProtocol = DataProviderService()
    
    var bmi: Double = 32
    var bmiType: WeightTypes = .overweight
    var bmiIndicators: [WeightTypes] = []
    var idealUserWeightString = ""
    var userNormalWeightString = ""
    var upToMyNormalWeightString = ""

    private var userLastWeight: Double = 0 {
        didSet {
            configure()
        }
    }
    
    private var userIdealKgWeight: Double = 0
    private var userCmHeight: Double = 183
    private var isMale = false
    private var isMetric = true
    private var weightMeas = ""
    private var userLowestNormalWeight: Double = 0
    private var userHighestNormalWeight: Double = 0
    
    // MARK: - Publick methods
    func configure() {
        getUserCmHeight()
        getUserMeasurementSystem()
        calculateBMI()
        getBMItype()
        getBmiIndicators()
        getUserGender()
        calculateIdealWeight()
        calculateUserNormalWeight()
        calculateUpToNormalWeight()
    }
    
    // MARK: - CALCULATE USER BMI
    private func calculateBMI() {
        isMetric ? calculateMetricalBMI() : calculateImperBMI()
    }
    
    private func calculateMetricalBMI() {
        let height = getUserHeight() / 100  // из футов в дюймы
        bmi = userLastWeight / pow(height, 2)
    }
    
    private func calculateImperBMI() {
        let height = getUserHeight() * 12 // из футов в дюймы
        bmi = userLastWeight / pow(height, 2) * 703
    }
                                
    private func getBMItype() {
        switch bmi {
        case 16..<17:       bmiType =  .sevUnderweigth
        case 17..<18.5:     bmiType =  .underweight
        case 18.5..<25:     bmiType =  .normalWeight
        case 25..<30:       bmiType =  .overweight
        case 30..<35:       bmiType =  .obeseClass1
        case 35..<40:       bmiType =  .obeseClass2
        case 40...:         bmiType =  .obeseClass3
        default:            bmiType =  .verySevUnderweigth
        }
    }
    
    private func getBmiIndicators() {
        bmiIndicators = [.verySevUnderweigth, .sevUnderweigth, .underweight, .normalWeight, .overweight, .obeseClass1, .obeseClass2, .obeseClass3]
    }
    
    // MARK: - DataBase private methods
    func getUserLastWeight(completion: @escaping () -> Void) {
        facade.fetchLastWeight { [weak self] sample in
            self?.userLastWeight = sample.doubleValue
            completion()
        }
    }

    private func getUserHeight() -> Double {
        var userHeight: Double = 0
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                userHeight = success.userHeight.actualLengthValue()
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        return userHeight
    }

    private func getUserMeasurementSystem() {
        if userSettingsService.getUserWeighthUnit() == R.string.localizable.unitsKg() && userSettingsService.getUserLenghtUnit() == R.string.localizable.unitsCm() {
            isMetric = true
            weightMeas = R.string.localizable.unitsKg()
        } else {
            isMetric = false
            weightMeas = R.string.localizable.unitsLbs()
        }
    }
    
    private func getUserGender() {
        isMale = userSettingsService.isUserMale
    }
    
    private func getUserCmHeight() {
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                let height = success.userHeight
                if isMetric {
                    userCmHeight = height
                } else {
                    let ftInCm: Double = 0.0328084
                    userCmHeight = height * ftInCm
                }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
    
    // MARK: - Calculate user weight indeces
    private func calculateUserNormalWeight() {
        let lowestNormalBmi: Double = 18.5
        let highestNormalBmi: Double = 24.99
        var userWeight = userLastWeight
        
        userLowestNormalWeight = Double(round(10 * (userWeight * lowestNormalBmi / bmi)) / 10)
        userHighestNormalWeight = Double(round(10 * (userWeight * highestNormalBmi / bmi)) / 10)
        
        userNormalWeightString = String(describing: userLowestNormalWeight) + " - " + String(describing: userHighestNormalWeight) + " " + weightMeas
        
        if !isMetric {
            userNormalWeightString = String(describing: userLowestNormalWeight) + " - " + "\(userHighestNormalWeight)" + " " + weightMeas
        }
    }
    
    private func calculateIdealWeight() {
        var startWeight: Double = 0
        isMale ? (startWeight = 50) : (startWeight = 45.5)
        
        var idealWeight: Double = 0
        let weightKgCoeff: Double = 2.3
        let inchInCm: Double = 0.393701
        
        if userCmHeight > 152.4 {
            let heightCmDiff = userCmHeight - 152.4
            let heightInchDiff = heightCmDiff * inchInCm
            
            idealWeight = startWeight + (weightKgCoeff * heightInchDiff)
            userIdealKgWeight = Double(round(10 * idealWeight) / 10)
            
            if isMetric {
                idealUserWeightString = String(describing: userIdealKgWeight) + " " + weightMeas
            } else {
                idealUserWeightString = String(describing: weightFromKgToLbs(from: userIdealKgWeight)) + " " + weightMeas
            }
        } else {
            userIdealKgWeight = 0
            idealUserWeightString = R.string.localizable.bmiWidgetImpossibleToCalc()
        }
    }
    
    private func weightFromKgToLbs(from kg: Double) -> Double {
        let lbsInKg: Double = 2.20462
        let lbsWeight = kg * lbsInKg
        return Double(round(10 * lbsWeight) / 10)
    }
    
    private func weightFromLbsToKg(from lbs: Double) -> Double {
        let lbsInKg: Double = 2.20462
        let kgWeight = lbs / lbsInKg
        return Double(round(10 * kgWeight) / 10)
    }
    
    private func calculateUpToNormalWeight() {
        var upToNormal: Double = 0
        let userWeight = userLastWeight
        if isMetric {
            if userWeight > userHighestNormalWeight {
                upToNormal = userHighestNormalWeight - userWeight
            } else if userLastWeight < userLowestNormalWeight {
                upToNormal = userLowestNormalWeight - userWeight
            } else {
                upToNormal = 0
            }
        } else {
            if userWeight > userHighestNormalWeight {
                upToNormal = userHighestNormalWeight - userWeight
            } else if userLastWeight < userLowestNormalWeight {
                upToNormal = userLowestNormalWeight - userWeight
            } else {
                upToNormal = 0
            }
        }
        upToNormal = Double(round(upToNormal * 10) / 10)
        if upToNormal > 0 {
            upToMyNormalWeightString = "+" + String(describing: upToNormal) + " " + weightMeas
        } else if upToNormal == 0 {
            upToMyNormalWeightString = "0"
        } else {
            upToMyNormalWeightString = String(describing: upToNormal) + " " + weightMeas
        }
    }
}
