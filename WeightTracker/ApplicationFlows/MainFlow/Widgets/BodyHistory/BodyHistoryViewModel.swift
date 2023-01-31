//
//  BodyHistoryViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import Foundation

struct AverageMeasurements {
    let datePeriod: String
    let averangeDimension: String
}

enum BodyHistoryPeriod {
    case daily
    case weekly
    case monthly
}

final class BodyHistoryViewModel {
    
    // MARK: - Services
    private let dataProviderService: DataProviderServiceProtocol = DataProviderService.shared
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    
    // MARK: - Properties
    var reloadHandler: (() -> Void)?
    var weightMeasurements: [WeightMeasurement] = []
    var hipMeasurements: [HipMeasurement] = []
    var chestMeasurements: [ChestMeasurement] = []
    var waistMeasurements: [WaistMeasurement] = []
    
    var weightMeasurementsFromHK: [MeasurementSample] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.reloadHandler?()
            }
        }
    }

    var averageMeasurements: [AverageMeasurements] = []
    var period: BodyHistoryPeriod = .daily  {
        didSet {
            fetchWeightMeasurementsFromHealthKit()
        }
    }
    
    // MARK: - Public methods
    func getMeasurements(for type: MeasurementTypes) {
        dbService.fetchAllMeasurements(measurementType: type) { result in
            switch result {
            case .success(let measurenments):
                switch type {
                case .chest:
                    chestMeasurements = measurenments as! [ChestMeasurement]
                case .waist:
                    waistMeasurements = measurenments as! [WaistMeasurement]
                case .hip:
                    hipMeasurements = measurenments as! [HipMeasurement]
                case .weight:
                    weightMeasurements = measurenments as! [WeightMeasurement]
                case .bmi:
                    return
                }
            case .failure(let failure):
                debugPrint("Problems with geting data from CoreData - \(failure.localizedDescription)")
            }
        }
    }
    
    func fetchWeightMeasurementsFromHealthKit() {
        dataProviderService.fetchWeightInfoConditionally { [weak self] samples in
            self?.weightMeasurementsFromHK = samples
        }
    }
    
    func deleteMeasurementFromDB(for type: MeasurementTypes, with indexPath: Int) {
        if type == .weight {
            if  weightMeasurementsFromHK[indexPath].isFromHK {
                return
            } else {
                dbService.deleteSpecificRecord(sample: weightMeasurementsFromHK[indexPath])
                return
            }
        }
        switch type {
        case .chest: dbService.deleteChestMeasurement(indexPath: indexPath)
        case .waist: dbService.deleteWaistMeasurement(indexPath: indexPath)
        case .hip: dbService.deleteHipMeasurement(indexPath: indexPath)
        case .weight: dbService.deleteWeightMeasurement(indexPath: indexPath)
        case .bmi: return
        }
    }
    
    func deleteMeasurementFromVM(for type: MeasurementTypes, indexPath: Int) {
        switch type {
        case .chest: chestMeasurements.remove(at: indexPath)
        case .waist: waistMeasurements.remove(at: indexPath)
        case .hip: hipMeasurements.remove(at: indexPath)
        case .weight: weightMeasurementsFromHK.remove(at: indexPath)
        case .bmi: return
        }
    }
    
    func getDataCount(for type: MeasurementTypes) -> Int {
        switch type {
        case .chest:   return chestMeasurements.count
        case .waist:   return waistMeasurements.count
        case .hip:     return hipMeasurements.count
        case .weight:  return weightMeasurementsFromHK.count
        case .bmi:     return weightMeasurements.count
        }
    }
    
    func isArrayEmpty(for type: MeasurementTypes) -> Bool {
        switch type {
        case .chest:   if chestMeasurements.isEmpty { return true } else { return false }
        case .waist:   if waistMeasurements.isEmpty { return true } else { return false }
        case .hip:     if hipMeasurements.isEmpty { return true } else { return false }
        case .weight:  if weightMeasurementsFromHK.isEmpty { return true } else { return false }
        case .bmi:     return true
        }
    }
    
    func getUserWidthUnit() -> String {
        return userSettingsService.getUserWeighthUnit()
    }
    
    func getUserLenghtUnit() -> String {
        return userSettingsService.getUserLenghtUnit()
    }
    
    // MARK: - Getting weekly average measurements
    func getWeightWeeklyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()
        var weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = weightMeasurementsFromHK
        
        guard let lastDate = templeArray.last?.date else { return }
        
        while currentDate >= lastDate {
            
            for i in 0..<templeArray.count {
                if templeArray[i].date > weekAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].value
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            let secondFormatter = DateFormatter()
            
            formatter.dateFormat = "MMM d"
            secondFormatter.dateFormat = "MMM d, yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: weekAgo))" + " - " + "\(secondFormatter.string(from: currentDate))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: weekAgo)!
            weekAgo = makeWeekAgoDate(date: currentDate)
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0

        }
    }
    
    func getChestWeeklyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()
        var weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = chestMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        
        while currentDate >= lastDate {
            
            for i in 0..<templeArray.count {
                if templeArray[i].date > weekAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].chest
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            let secondFormatter = DateFormatter()
            
            formatter.dateFormat = "MMM d"
            secondFormatter.dateFormat = "MMM d, yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: weekAgo))" + " - " + "\(secondFormatter.string(from: currentDate))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: weekAgo)!
            weekAgo = makeWeekAgoDate(date: currentDate)
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0

        }
    }
    
    func getWaistWeeklyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()
        var weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = waistMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        
        while currentDate >= lastDate {
            
            for i in 0..<templeArray.count {
                if templeArray[i].date > weekAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].waist
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            let secondFormatter = DateFormatter()
            
            formatter.dateFormat = "MMM d"
            secondFormatter.dateFormat = "MMM d, yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: weekAgo))" + " - " + "\(secondFormatter.string(from: currentDate))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: weekAgo)!
            weekAgo = makeWeekAgoDate(date: currentDate)
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0

        }
    }
    
    func getHipWeeklyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()
        var weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = hipMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        
        while currentDate >= lastDate {
            
            for i in 0..<templeArray.count {
                if templeArray[i].date > weekAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].hip
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            let secondFormatter = DateFormatter()
            
            formatter.dateFormat = "MMM d"
            secondFormatter.dateFormat = "MMM d, yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: weekAgo))" + " - " + "\(secondFormatter.string(from: currentDate))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: weekAgo)!
            weekAgo = makeWeekAgoDate(date: currentDate)
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0

        }
    }
    
    private func makeWeekAgoDate(date: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: date)!
    }
    
    // MARK: - Getting monthly average dimension
    func getWeightMonthlyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()

        let firstDayOfCurrentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
        var monthAgo = Calendar.current.date(byAdding: .day, value: +1, to: firstDayOfCurrentMonth)!
        
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = weightMeasurementsFromHK
        
        guard let lastDate = templeArray.last?.date else { return }
        let firstDayOfLastMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: lastDate)))!
        
        while currentDate >= firstDayOfLastMonth {

            for i in 0..<templeArray.count {
                if templeArray[i].date > monthAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].value
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMM yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: monthAgo))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: monthAgo)!
            
            monthAgo = currentDate
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0
        }
    }
    
    func getWaistMonthlyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()

        let firstDayOfCurrentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
        var monthAgo = Calendar.current.date(byAdding: .day, value: +1, to: firstDayOfCurrentMonth)!
        
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = waistMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        let firstDayOfLastMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: lastDate)))!
        
        while currentDate >= firstDayOfLastMonth {

            for i in 0..<templeArray.count {
                if templeArray[i].date > monthAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].waist
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMM yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: monthAgo))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: monthAgo)!
            
            monthAgo = currentDate
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0
        }
    }
    
    func getChestMonthlyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()

        let firstDayOfCurrentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
        var monthAgo = Calendar.current.date(byAdding: .day, value: +1, to: firstDayOfCurrentMonth)!
        
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = chestMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        let firstDayOfLastMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: lastDate)))!
        
        while currentDate >= firstDayOfLastMonth {

            for i in 0..<templeArray.count {
                if templeArray[i].date > monthAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].chest
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMM yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: monthAgo))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: monthAgo)!
            
            monthAgo = currentDate
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0
        }
    }
    
    func getHipMonthlyAverageMeasurements() {
        if !averageMeasurements.isEmpty {
            averageMeasurements = []
        }
        var currentDate = Date()

        let firstDayOfCurrentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
        var monthAgo = Calendar.current.date(byAdding: .day, value: +1, to: firstDayOfCurrentMonth)!
        
        var dimentionsInWeek: Double = 0
        var sumDimensionsInWeek: Double = 0
        var templeArray = hipMeasurements
        
        guard let lastDate = templeArray.last?.date else { return }
        let firstDayOfLastMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: lastDate)))!
        
        while currentDate >= firstDayOfLastMonth {

            for i in 0..<templeArray.count {
                if templeArray[i].date > monthAgo {
                    dimentionsInWeek += 1
                    sumDimensionsInWeek += templeArray[i].hip
                }
            }
            
            for _ in 0...Int(dimentionsInWeek) {
                if templeArray.count != 1 {
                    templeArray.removeFirst()
                }
            }
            
            let averageWeekDimension = round(sumDimensionsInWeek / dimentionsInWeek * 10) / 10.0
            let stringAverageWeekDimension = String(averageWeekDimension)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMM yyyy"
            
            let stringDatePeriod = "\(formatter.string(from: monthAgo))"
            
            if stringAverageWeekDimension != "nan" {
                averageMeasurements.append(.init(datePeriod: stringDatePeriod, averangeDimension: stringAverageWeekDimension))
            }
            
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: monthAgo)!
            
            monthAgo = currentDate
            dimentionsInWeek = 0
            sumDimensionsInWeek = 0
        }
    }
    
    private func makeMonthAgoDate(date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date)!
    }
}
