//
//  MeasurementsViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import Amplitude
import Foundation

final class MeasurementsViewModel {
    
    // MARK: - Services
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    private let amplitude = Amplitude.instance()
    
    // MARK: - Properties
    private var measurementResult: Double = 0
    private var type: MeasurementTypes
    var measurementStringResult: String = ""
    
    // MARK: - Init
    init(type: MeasurementTypes) {
        self.type = type
    }
    
    // MARK: - Publick methods
    func addMeasurement(for type: MeasurementTypes) {
        getMeasurementResult()
        switch type {
        case .chest:
            dbService.addChestMeasurement(value: measurementResult)
        case .waist:
            dbService.addWaistMeasurement(value: measurementResult)
        case .hip:
            dbService.addHipMeasurement(value: measurementResult)
        case .weight:
            dbService.addWeightMeasurement(value: measurementResult)
        case .bmi:
            return
        }
    }
    
    func getUserWidthUnit() -> String {
        return " \(userSettingsService.getUserWeighthUnit())"
    }
    
    func getUserLenghtUnit() -> String {
        return " \(userSettingsService.getUserLenghtUnit())"
    }
    
    // MARK: - AMPLITUDE
    func amplitudeLogEvent() {
        amplitude.logEvent(type.logKey)
    }
    
    // MARK: - VALIDATION
    func isMeasurementResultValid(for type: MeasurementTypes) -> Validation {
        
        if measurementStringResult.last == "." &&  measurementStringResult.last == "," {
            return .incorrectData
        } else if measurementStringResult == "" || measurementStringResult == " " {
            return .empty
        }
        
        guard let result = Double(measurementStringResult.replaceDot()) else { return .incorrectData }

        if type == .weight {
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
            
        } else {
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
        }
    }
    
    // MARK: - Private methods
    private func getMeasurementResult() {
        let doubleResult = Double(measurementStringResult.replaceDot()) ?? 0
        measurementResult = type != .weight
        ? userSettingsService.isImperial
        ?  doubleResult.ftToCm()
        : doubleResult
        : userSettingsService.isImperial
        ? doubleResult.lbsToKgs()
        : doubleResult
    }
}
