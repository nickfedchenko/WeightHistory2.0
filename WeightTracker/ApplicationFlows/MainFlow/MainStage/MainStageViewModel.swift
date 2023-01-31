//
//  MainStageViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import Amplitude
import UIKit

final class MainStageViewModel {
    
    // MARK: - Service properties
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    private var widgetSizeService = WidgetSizeService()
    private let dataProviderService: DataProviderServiceProtocol = DataProviderService.shared
    private let amplitude = Amplitude.instance()
    
    // MARK: - Public properties
    var userLengthUnit = R.string.localizable.unitsCm()
    var sideIndent: Double = 0
    var largeWidgetHeight: Double = 0
    var mediumWidgetHeight: Double = 0
    var compactWidgetHeight: Double = 0
    var smallWidgetHeight: Double = 0
    var widgetWidth: Double = 0
    var isDeviceOld: Bool {
        UIDevice.screenType == .less ? true : false
    }
        
    var chartCurrentPeriod: WTChartViewModel.WTChartPeriod = .week
    var chartCurrentMode: WTChartViewModel.WTChartMode = .weight
    var isAppWasLaunched = false
    
    // MARK: - Init
    init() {
        getUserLenghtUnit()
        getMediumWidgetHeight()
        getSideIndent()
        getCompactWidgetHeight()
        getSmallWidgetHeight()
        getLargeWidgetHeight()
    }
    
    // MARK: - GET DATA FROM DB
    func getDataForChart(for type: MeasurementTypes, period: Int, completion: @escaping ([WTGraphRawDataModel]) -> Void) {
        var chartData: [WTGraphRawDataModel] = []
        dbService.fetchMeasurements(measurementType: type, period: period) { result in
            switch result {
            case .success(let measurenments):
                switch type {
                case .chest:
                    chartData = measurenments as! [ChestMeasurement]
                    completion(chartData)
                case .waist:
                    chartData = measurenments as! [WaistMeasurement]
                    completion(chartData)
                case .hip:
                    chartData = measurenments as! [HipMeasurement]
                    completion(chartData)
                case .weight:
                    chartData = measurenments as! [WeightMeasurement]
                    dataProviderService.fetchWeightInfoConditionally { samples in
                        completion(samples)
                    }
                case .bmi:
                    let weightMeasurements = measurenments as! [WeightMeasurement]
                    dataProviderService.fetchWeightInfoConditionally { [weak self] samples in
                        guard let self = self else { return }
                        chartData = self.setBMIDataForChart(from: samples)
                        completion(chartData)
                    }
                   
                }
            case .failure(let failure):
                debugPrint("Problems with geting data from CoreData - \(failure.localizedDescription)")
            }
        }
    }
    
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
    
    //MARK: - CALCULATE BMI
    private func setBMIDataForChart(from weightMeasurements: [MeasurementSample]) -> [BMIArrayModel] {
        var bmiArray: [BMIArrayModel] = []
        
        for i in weightMeasurements {
            bmiArray.append(.init(value: calculateBMI(for: i.doubleValue), date: i.date))
        }
        return bmiArray
    }
    
    private func calculateBMI(for weight: Double) -> Double {
        isMetrical() == true ? calculateMetricalBMI(for: weight) : calculateImperBMI(for: weight)
    }
    
    private func calculateMetricalBMI(for weight: Double) -> Double {
        let height = getUserHeight() / 100   // из см в метры
        return weight / (height * height)
    }
    
    private func calculateImperBMI(for weight: Double) -> Double {
        let height = getUserHeight() * 12    // из футов в дюймы
        let coefficient: Double = 703       // коэф для вычистления bmi в импречиской системме
        return (weight / (height * height)) * coefficient
    }
    
    private func isMetrical() -> Bool {
        if userSettingsService.getUserWeighthUnit() == R.string.localizable.unitsKg() && userSettingsService.getUserLenghtUnit() == R.string.localizable.unitsCm() {
            return true
        } else {
            return false
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
    
    private func getUserLenghtUnit() {
        userLengthUnit = userSettingsService.getUserLenghtUnit()
    }
    
    //MARK: - FETCHING LAST MEASUREMENT FOR - HIP WAIST CHEST
    func getLastMeasurement(for widgetType: MeasurementTypes) -> String {
        var lastMeasurement: Double = 0
        var lastMeasurementString = ""
        getUserLenghtUnit()
        
        dbService.fetchLastMeasurement(measurementType: widgetType) { result in
            switch result {
            case .success(let success):
                switch widgetType {
                case .chest:
                    let data = success as! ChestMeasurement
                    lastMeasurement = data.chest.actualLengthValue()
                case .waist:
                    let data = success as! WaistMeasurement
                    lastMeasurement = data.waist.actualLengthValue()
                case .hip:
                    let data = success as! HipMeasurement
                    lastMeasurement = data.hip.actualLengthValue()
                case .weight:   return
                case .bmi:      return
                }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        
        if lastMeasurement == 0 {
            lastMeasurementString = "-:-"
        } else {
            if String(lastMeasurement).hasSuffix(".0") {
                lastMeasurementString = "\(String(lastMeasurement).dropLast(2)) " + userLengthUnit
            } else {
                lastMeasurementString = "\(String(format: "%.1f", lastMeasurement)) " + userLengthUnit
            }
        }
        return lastMeasurementString
    }
    
    // MARK: - APMLITUDE METHODS
    func bmiAmplitudeLogEvent() {
        amplitude.logEvent("bmiTap")
    }
    
    func currentWeightWidgetAmplitudeLogEvent() {
        amplitude.logEvent("weightTap")
    }
    
    func compactChestWidgetAmplitudeLogEvent() {
        amplitude.logEvent("chestTap")
    }
    
    func compactHipWidgetAmplitudeLogEvent() {
        amplitude.logEvent("hipTap")
    }
    
    func compactWaistWidgetAmplitudeLogEvent() {
        amplitude.logEvent("waistTap")
    }
    
    func fastAddWidgetAmplitudeLogEvent() {
        amplitude.logEvent("fastWeightAddTap")
    }
    
    //MARK: - WIDGETS SIZE & INDENTS
    private func getSideIndent() {
        sideIndent = widgetSizeService.sideIndent
    }
    
    private func getMediumWidgetHeight() {
        widgetSizeService.type = .medium
        widgetWidth = widgetSizeService.widgetWidth
        mediumWidgetHeight = widgetSizeService.height
    }
    
    private func getCompactWidgetHeight() {
        widgetSizeService.type = .compact
        compactWidgetHeight = widgetSizeService.height
    }
    
    private func getSmallWidgetHeight() {
        widgetSizeService.type = .small
        smallWidgetHeight = widgetSizeService.height
    }
    
    private func getLargeWidgetHeight() {
        widgetSizeService.type = .large
        largeWidgetHeight = widgetSizeService.height
    }
    
}
