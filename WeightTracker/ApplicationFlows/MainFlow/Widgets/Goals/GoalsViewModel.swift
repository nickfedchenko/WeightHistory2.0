//
//  GoalsViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

enum GoalsRusString {
    case plural
    case singular

    var rawValue: String {
        switch self {
        case .plural:
            return "этапов"
        case .singular:
            return "этапа"
        }
    }
}

struct GoalsModel {
    let goalsLabelText: String
    let goalsIndex: Double
}

final class GoalsViewModel {
    
    // MARK: - Property list
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    
    private var isUserLoseWeight = true
    private var isMetric = true
    
    private let facade: DataProviderServiceProtocol = DataProviderService()
    
    // MARK: - Public properties
    var milestoneString: String = ""
    var userStartWeight: Double = 0
    var userGoalWeight: Double = 0
    var milestones: Int = 10
    var oneMile: Double = 0
    var userCurrentWeight: Double = 0
    var userWeightUnit: String = ""
    var userWeightProgress: Double = 0
    var milestoneProgress: Double = 0
    var mileStoneToGo: Double = 0
    var overallToGo: Double = 0
    var userWeightDiff: Double = 0
    var weightDiffProgress: Double = 0
    
    var goalsArray: [GoalsModel] = []
    var tableViewHeight = 0
    var nextStepIndex = 0
    var currentStepIndex = 0
    
    var isUserMaintainWeight = false
    var isDeviceOld: Bool {
        UIDevice.screenType == .less ? true : false
    }
    
    var isSplitGoalSelected = true {
        willSet {
            saveIsSplitGoal(value: newValue)
        }
    }
    
    // MARK: - Configure
    func configure() {
        
        getUserStartAndGoalWeight()
        getUserWeightUnit()
        getUserCurrentWeight { [weak self] in
            guard let self = self else { return }
            self.getMilestonesNumber()
            self.makeMilestonesString()
            
            if self.isUserMaintainWeight {
                self.calculateUserWeightDiff()
                self.calculateWeightDiffProgress()
            } else {
                self.getIsUserSplitGoal()
                self.calculateOneMile()
                self.makeGoalsArray()
                self.calculateNextStep()
                self.getTableViewHeight()
                self.calculateUserWeightProgress()
                self.calculateMilestoneToGo()
                self.calculateMilestoneProgress()
                self.calculateOverallToGo()
            }
        }
    }
    
    // MARK: - FETCHING DATA FROM COREDATA
    private func getUserStartAndGoalWeight() {
        dbService.fetchDomainUserInfo { result in
            switch result {
            case .success(let success):
                userStartWeight = roundTen(success.userStartWeight.actualWeightValue())
                userGoalWeight = roundTen(success.userGoalWeight.actualWeightValue())
                
                success.userGoal ?? R.string.localizable.onboardingGoalLoseWeight() ==  R.string.localizable.onboardingGoalLoseWeight() ? (isUserLoseWeight = true) : (isUserLoseWeight = false)
                
                if success.userGoal ?? R.string.localizable.onboardingGoalLoseWeight() == R.string.localizable.onboardingGoalMaintainWeight() {
                    isUserMaintainWeight = true
                    isSplitGoalSelected = false
                } else {
                    isUserMaintainWeight = false
                }
                
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
    
    private func getUserCurrentWeight(completion: @escaping () -> Void) {
        facade.fetchLastWeight { [weak self] result in
            self?.userCurrentWeight = roundTen(result.doubleValue)
            if self?.userCurrentWeight == 0 {
                self?.userCurrentWeight = self?.userStartWeight ?? 50
            }
            completion()
        }
    }
    
    // MARK: - USER SETTINGS
    private func getUserWeightUnit() {
        if userSettingsService.getUserWeighthUnit() == R.string.localizable.unitsKg() {
            isMetric = true
            userWeightUnit = R.string.localizable.unitsKg()
        } else {
            isMetric = false
            userWeightUnit = R.string.localizable.unitsLbs()
        }
    }
    
    private func getIsUserSplitGoal() {
        isSplitGoalSelected = userSettingsService.getIsUserSplitGoal()
    }
    
    private func saveIsSplitGoal(value: Bool) {
        userSettingsService.setIsUserSplitGoal(value: value)
    }
    
    private func getMilestonesNumber() {
        milestones = userSettingsService.getMilestonesNumber()
    }
    
    func saveMilestonesNumber(index: Int) {
        userSettingsService.setMilestonesNumber(index: index)
    }
    
    // MARK: - CALCULATE GOALS
    private func calculateOneMile() {
        if isUserLoseWeight {
            oneMile = (userStartWeight - userGoalWeight) / Double((milestones))
        } else {
            oneMile = (userStartWeight - userGoalWeight) / Double((milestones)) * Double(-1)
        }
        oneMile = roundTen(oneMile)
    }
    
    func calculateOneMileForPicker(milestoneIndex: Int) -> String {
        var oneMileForPicker: Double = 0
        if isUserLoseWeight {
            oneMileForPicker = (userStartWeight - userGoalWeight) / Double((milestoneIndex))
        } else {
            oneMileForPicker = (userStartWeight - userGoalWeight) / Double((milestoneIndex)) * Double(-1)
        }
        oneMileForPicker = roundTen(oneMileForPicker)
        return "\(oneMileForPicker) " + userWeightUnit
    }
    
    private func calculateNextStep() {
        nextStepIndex = 0
        for i in 0..<goalsArray.count {
            if userCurrentWeight == userStartWeight {
                nextStepIndex = 1
            }
            
            if isUserLoseWeight {
                if userCurrentWeight > userStartWeight {
                    nextStepIndex = 1
                }
                if userCurrentWeight <= goalsArray[i].goalsIndex {
                    nextStepIndex = i + 1
                }
            } else {
                if userCurrentWeight < userStartWeight {
                    nextStepIndex = 1
                }
                if userCurrentWeight >= goalsArray[i].goalsIndex {
                    nextStepIndex = i + 1
                }
            }
        }
        currentStepIndex = nextStepIndex - 1
    }
    
    private func calculateUserWeightProgress() {
        if isUserLoseWeight {
            let progress = userStartWeight - userCurrentWeight
            let fullWay = userStartWeight - userGoalWeight
            if userCurrentWeight > userStartWeight {
                userWeightProgress = 0
            } else if userCurrentWeight < userGoalWeight {
                userWeightProgress = 1
            } else {
                userWeightProgress = progress / fullWay
            }
        } else {
            let fullWay = userGoalWeight - userStartWeight
            let progress = userCurrentWeight - userStartWeight
            if userCurrentWeight > userGoalWeight {
                userWeightProgress = 1
            } else if userCurrentWeight < userStartWeight {
                userWeightProgress = 0
            } else {
                userWeightProgress = progress / fullWay
            }
        }
    }
    
    private func calculateMilestoneToGo() {
        if isUserLoseWeight && userCurrentWeight <= userGoalWeight{
            nextStepIndex -= 1
        }
        if !isUserLoseWeight && userCurrentWeight >= userGoalWeight {
            nextStepIndex -= 1
        }
        mileStoneToGo = roundTen(goalsArray[nextStepIndex].goalsIndex - userCurrentWeight)
        if mileStoneToGo < 0 {
            mileStoneToGo = mileStoneToGo * (-1)
        }
    }
    
    private func calculateOverallToGo() {
        overallToGo = roundTen(userGoalWeight - userCurrentWeight)
        if overallToGo < 0 {
            overallToGo = overallToGo * (-1)
        }
    }
    
    private func calculateMilestoneProgress() {
        let currnetMilestoneFullWay = goalsArray[nextStepIndex].goalsIndex - goalsArray[nextStepIndex - 1].goalsIndex
        
        if isUserLoseWeight {
            if userCurrentWeight > userStartWeight {
                milestoneProgress = 0
            } else if userCurrentWeight < userGoalWeight {
                milestoneProgress = 100
            } else {
                let passedMilestoneWay = userCurrentWeight - goalsArray[nextStepIndex - 1].goalsIndex
                milestoneProgress = roundTen((100 * passedMilestoneWay) / currnetMilestoneFullWay)
                if milestoneProgress == -0.0 {
                    milestoneProgress = 0.0
                }
            }
        } else {
            if userCurrentWeight > userGoalWeight {
                milestoneProgress = 100
            } else if userCurrentWeight < userStartWeight {
                milestoneProgress = 0
            } else {
                let passedMilestoneWay = userCurrentWeight - goalsArray[nextStepIndex - 1].goalsIndex
                milestoneProgress = roundTen((100 * passedMilestoneWay) / currnetMilestoneFullWay)
                if milestoneProgress == -0.0 {
                    milestoneProgress = 0.0
                }
            }
        }
    }
    
    private func calculateUserWeightDiff() {
        userWeightDiff = userCurrentWeight - userGoalWeight
    }
    
    private func calculateWeightDiffProgress() {
        let zeroProgress: Double = 0.5
        var onePoint: Double = 0
        
        if isMetric {
            onePoint = 0.05
        } else {
            onePoint = 0.11
        }
        
        if userWeightDiff == 0 {
            weightDiffProgress = zeroProgress
        } else if userWeightDiff < 0 {
            weightDiffProgress = zeroProgress - ((userGoalWeight - userCurrentWeight) * onePoint)
        } else if userWeightDiff > 0 {
            weightDiffProgress = zeroProgress + ((userCurrentWeight - userGoalWeight) * onePoint)
        }
        
        if weightDiffProgress > 1 {
            weightDiffProgress = 1
        } else if weightDiffProgress < 0 {
            weightDiffProgress = 0
        }
    }
    
    // MARK: - Other private methods
    private func getTableViewHeight() {
        tableViewHeight = 28 * (milestones + 1)
    }
    
    private func makeGoalsArray() {
        var mileWeight = userStartWeight
        goalsArray = []
        for i in 0...milestones {
            if i == 0 {
                goalsArray.append(.init(goalsLabelText: R.string.localizable.milestoneMileStartWeight(), goalsIndex: roundTen(mileWeight)))
            } else if i == milestones {
                goalsArray.append(.init(goalsLabelText: R.string.localizable.milestoneMileGoaltWeight(), goalsIndex: userGoalWeight))
            } else {
                isUserLoseWeight == true ? (mileWeight -= oneMile) : (mileWeight += oneMile)
                goalsArray.append(.init(goalsLabelText: R.string.localizable.milestoneMilestone() + "\(i)", goalsIndex: roundTen(mileWeight)))
            }
        }
    }
    
    private func makeMilestonesString() {
        if Locale.isLanguageRus && milestones < 5 {
            milestoneString = GoalsRusString.singular.rawValue
        } else if Locale.isLanguageRus && milestones > 4 {
            milestoneString = GoalsRusString.plural.rawValue
        } else {
            milestoneString = R.string.localizable.milestoneMilestones()
        }
    }
}
