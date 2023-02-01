//
//  DataProviderService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import Foundation
import CoreData
import HealthKit

protocol DataProviderServiceProtocol {
    func saveDomainUserGender(with gender: String)

    func saveDomainUserBirthday(with date: Date)

    func saveDomainUserHeight(with height: Double)

    func saveDomainUserStartWeight(with weight: Double)

    func saveDomainUserGoalWeight(with weight: Double)

    func saveDomainUserGoal(with goal: String)

    func saveDomainUserWeightFrequency(with answer: String)

    func addHipMeasurement(result: Double)

    func addWaistMeasurement(result: Double)

    func addChestMeasurement(result: Double)

    func addWeightMeasurement(result: Double)

    func deleteWeightMeasurement(indexPath: Int)

    func deleteHipMeasurement(indexPath: Int)

    func deleteChestMeasurement(indexPath: Int)

    func deleteWaistMeasurement(indexPath: Int)

    func fetchFirstUserInfo(completion: (Result<DomainUser, Error>) -> Void)

    func fetchAllMeasurements<T: NSManagedObject>(for measType: MeasurementTypes, completion: (Result<[T], CDError>) -> Void)

    func fetchLastMeasurement<T: NSManagedObject>(for measType: MeasurementTypes, completion: (Result<T, CDError>) -> Void)

    func fetchMeasurements(for measType: MeasurementTypes, period: Int, completion: (Result<[NSFetchRequestResult], Error>) -> Void)
    
    func requestPermission(completion: @escaping (Bool) -> Void)

    func fetchSamples(for sampleType: HKSampleType, fromDate: Date, toDate: Date, completion: @escaping ([HKQuantitySample]?, Error?) -> Swift.Void)
    
    func fetchWeightInfoConditionally(completion: @escaping ([MeasurementSample]) -> Void)
    
    func fetchLastWeight(completion: @escaping (MeasurementSample) -> Void)
}

struct MeasurementSample: WTGraphRawDataModel {
    var value: CGFloat {
        return doubleValue
    }
    let doubleValue: Double
    let date: Date
    let isFromHK: Bool
}

final class DataProviderService: DataProviderServiceProtocol {
  
    static let shared = DataProviderService()
    
    private let healthKitService = HealthKitService.shared
    private let dbService = CoreDataService.shared
    private let userSettingsService = UserSettingsService.shared
    
    func saveDomainUserGender(with gender: String) {
        
    }
    
    func saveDomainUserBirthday(with date: Date) {
        dbService.saveUserBirthday(date: date)
    }
    
    func saveDomainUserHeight(with height: Double) {
        dbService.saveUserHeight(value: height)
    }
    
    func saveDomainUserStartWeight(with weight: Double) {
        dbService.saveUserStartWeight(value: weight)
    }
    
    func saveDomainUserGoalWeight(with weight: Double) {
        dbService.saveUserGoalWeight(value: weight)
    }
    
    func saveDomainUserGoal(with goal: String) {
        dbService.saveUserGoal(answer: goal)
    }
    
    func saveDomainUserWeightFrequency(with answer: String) {
        dbService.saveUserWeightFrequency(answer: answer)
    }
    
    func addHipMeasurement(result: Double) {
        dbService.addHipMeasurement(value: result)
    }
    
    func addWaistMeasurement(result: Double) {
        dbService.addWaistMeasurement(value: result)
    }
    
    func addChestMeasurement(result: Double) {
        dbService.addChestMeasurement(value: result)
    }
    
    func addWeightMeasurement(result: Double) {
        dbService.addWeightMeasurement(value: result)
    }
    
    func deleteWeightMeasurement(indexPath: Int) {
        dbService.deleteWeightMeasurement(indexPath: indexPath)
    }
    
    func deleteHipMeasurement(indexPath: Int) {
        dbService.deleteHipMeasurement(indexPath: indexPath)
    }
    
    func deleteChestMeasurement(indexPath: Int) {
        dbService.deleteChestMeasurement(indexPath: indexPath)
    }
    
    func deleteWaistMeasurement(indexPath: Int) {
        dbService.deleteWaistMeasurement(indexPath: indexPath)
    }
    
    func fetchFirstUserInfo(completion: (Result<DomainUser, Error>) -> Void) {
        dbService.fetchDomainUserInfo(completion: completion)
    }
    
    func fetchAllMeasurements<T: NSManagedObject> (for measType: MeasurementTypes, completion: (Result<[T], CDError>) -> Void) {
        dbService.fetchAllMeasurements(measurementType: measType, completion: completion)
    }
    
    func fetchLastMeasurement<T: NSManagedObject>(for measType: MeasurementTypes, completion: (Result<T, CDError>) -> Void) {
        dbService.fetchLastMeasurement(measurementType: measType, completion: completion)
    }
    
    func fetchMeasurements(for measType: MeasurementTypes, period: Int, completion: (Result<[NSFetchRequestResult], Error>) -> Void) {
        dbService.fetchMeasurements(measurementType: measType, period: period, completion: completion)
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        healthKitService.requestPermission(completion: completion)
    }
    
    func fetchSamples(for sampleType: HKSampleType, fromDate: Date, toDate: Date, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        healthKitService.fetchSamples(for: sampleType, fromDate: fromDate, toDate: toDate, completion: completion)
    }
    
    func fetchWeightInfoConditionally(completion: @escaping ([MeasurementSample]) -> Void) {
        var localMeasurements: [WeightMeasurement] = []
        var hkSamples: [HKQuantitySample] = []
        dbService.fetchAllMeasurements(measurementType: .weight) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(measurements):
                if measurements.count > 0 {
                    localMeasurements = measurements as! [WeightMeasurement]
                }
                if userSettingsService.getIsAppleHealthOn() {
                    let startDate: Date = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
                    self.fetchSamples(for: .quantityType(forIdentifier: .bodyMass)!, fromDate: startDate, toDate: Date()) { samples, error in
                        guard let samples = samples else { return }
                        hkSamples = samples
                        let localSamples: [MeasurementSample] = localMeasurements.map {
                            .init(doubleValue: $0.weight.actualWeightValue(), date: $0.preciseDate, isFromHK: false)
                        }
                   
                        let hkMappedSamples: [MeasurementSample] = hkSamples.map {
                            .init(doubleValue: $0.quantity.doubleValue(for: UserSettingsService.shared.isImperial ? .pound() : .gramUnit(with: .kilo)), date: $0.startDate, isFromHK: true)
                        }
                        let preparedSamples = self.makeUnitedSamples(localSamples: localSamples, hkSamples: hkMappedSamples)
                        completion(preparedSamples)
                    }
                } else {
                    guard let localMeasurements = measurements as? [WeightMeasurement] else { return }
                    completion(localMeasurements.map {
                        .init(doubleValue: $0.weight.actualWeightValue(), date: $0.date, isFromHK: false)
                    })
                }
            case .failure(let error):
                print(error)
                if userSettingsService.getIsAppleHealthOn() {
                    let startDate: Date = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
                    self.fetchSamples(for: .quantityType(forIdentifier: .bodyMass)!, fromDate: startDate, toDate: Date()) { samples, error in
                        guard let samples = samples else {
                            completion([])
                            return
                        }
                      
                        let hkMappedSamples: [MeasurementSample] = samples.map {
                            return .init(doubleValue: $0.quantity.doubleValue(for: UserSettingsService.shared.isImperial ? .pound() : .gramUnit(with: .kilo)), date: $0.startDate, isFromHK: true)
                        }
                        let preparedSamples = self.makeUnitedSamples(localSamples: [], hkSamples: hkMappedSamples)
                        completion(preparedSamples)
                    }
                } else {
                    completion([])
                }
            }
        }
    }
    
    private func makeUnitedSamples(localSamples: [MeasurementSample], hkSamples: [MeasurementSample]) -> [MeasurementSample] {
        var dates: Set<Date> = []
        localSamples.forEach {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: $0.date)
            if let givenDate = formatter.date(from: dateString) {
                dates.update(with: givenDate)
            }
        }
     
        hkSamples.forEach {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: $0.date)
            if let givenDate = formatter.date(from: dateString) {
                dates.update(with: givenDate)
            }
        }
     
        var unifiedSamples: [MeasurementSample] = []
        
        for date in dates {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let stringDate = formatter.string(from: date)
            
            if let localMeasurement = localSamples.first (where: { sample in
                let localStringDate = formatter.string(from: sample.date)
                return stringDate == localStringDate
            }
            ){
                let filteredHKSamples = hkSamples.filter { sample in
                    let hkStringDate = formatter.string(from: sample.date)
                    return hkStringDate == stringDate
                }
                
                if !filteredHKSamples.isEmpty {
                    if let actualSample = filteredHKSamples.sorted(by: { $0.date > $1.date}).first {
                        if actualSample.date > localMeasurement.date {
                            let stringDate = formatter.string(from: actualSample.date)
                            let unifiedDate = formatter.date(from: stringDate) ?? Date()
                            let unifiedDateSample = MeasurementSample(doubleValue: actualSample.doubleValue, date: unifiedDate, isFromHK: true)
                            unifiedSamples.append(unifiedDateSample)
                        } else {
                            let stringDate = formatter.string(from: localMeasurement.date)
                            let unifiedDate = formatter.date(from: stringDate) ?? Date()
                            let prepapredLocalMeasurement: MeasurementSample = .init(doubleValue: localMeasurement.doubleValue, date: unifiedDate, isFromHK: localMeasurement.isFromHK)
                            unifiedSamples.append(prepapredLocalMeasurement)
                        }
                    }
                } else {
                    let stringDate = formatter.string(from: localMeasurement.date)
                    let unifiedDate = formatter.date(from: stringDate) ?? Date()
                    let prepapredLocalMeasurement: MeasurementSample = .init(doubleValue: localMeasurement.doubleValue, date: unifiedDate, isFromHK: localMeasurement.isFromHK)
                    unifiedSamples.append(prepapredLocalMeasurement)
                }
            } else {
                let filteredHKSamples = hkSamples.filter { sample in
                    let hkStringDate = formatter.string(from: sample.date)
                    return hkStringDate == stringDate
                }
                if let actualSample = filteredHKSamples.sorted(by: { $0.date > $1.date}).first {
                    let stringDate = formatter.string(from: actualSample.date)
                    let unifiedDate = formatter.date(from: stringDate) ?? Date()
                    let unifiedDateSample = MeasurementSample(doubleValue: actualSample.doubleValue, date: unifiedDate, isFromHK: true)
                    unifiedSamples.append(unifiedDateSample)
                }
            }
        }
        return unifiedSamples.sorted(by: { $0.date > $1.date })
    }
    
    func fetchLastWeight(completion: @escaping (MeasurementSample) -> Void) {
        fetchWeightInfoConditionally { samples in
            guard let sample = samples.first else {
                completion(.init(doubleValue: 0, date: Date(), isFromHK: false))
                return
            }
            completion(sample)
        }
    }
}
