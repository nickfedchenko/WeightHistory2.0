//
//  HealthKitService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import HealthKit
import UIKit

final class HealthKitService {
    
    static let shared = HealthKitService()
    
    // MARK: - Properties
    var isActive: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    let writeTypes: Set<HKSampleType> = [.quantityType(forIdentifier: .bodyMass)!]
    let readTypes: Set<HKSampleType> = [
        .quantityType(forIdentifier: .bodyMass)!
    ]
    
    let store = HKHealthStore()
    
    // MARK: - Publick methods
    func requestPermission (completion: @escaping (Bool) -> Void) {
        store.requestAuthorization(toShare: writeTypes, read: readTypes) { [weak self] isSuccess, error in
            guard let self = self else {
                completion(false)
                return
            }
            if let error = error {
                debugPrint(error)
                completion(false)
            } else {
                completion(self.checkAuthorizationStatus())
            }
        }
    }
    
    func checkAuthorizationStatus() -> Bool {
        let status = store.authorizationStatus(for: .quantityType(forIdentifier: .bodyMass)!)
        return status == .sharingAuthorized
    }
    
    func fetchSamples(
        for sampleType: HKSampleType,
        fromDate: Date,
        toDate: Date = Date(),
        completion: @escaping ([HKQuantitySample]?, Error?
        ) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: fromDate,
            end: toDate,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )
        
        let sampleQuery = HKSampleQuery(
            sampleType: sampleType,
            predicate: mostRecentPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample] else {
                    completion(nil, error)
                    return
                }
                completion(samples, nil)
            }
        }
        store.execute(sampleQuery)
    }
}
