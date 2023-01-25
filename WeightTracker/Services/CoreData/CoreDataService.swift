//
//  CoreDataService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit
import CoreData

final class CoreDataService {
    
    static let shared = CoreDataService()
    
    // MARK: - Property list
    private lazy var context = persistentContainer.viewContext
    private let formatter = DateFormatter()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Persistent container
    private var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "WeightTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        return container
    }()
    
    // MARK: - SAVING USER INFO
    func saveUserGender(value: Int16) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        if object?.count == 0 {
            let user = DomainUser(context: context)
            user.userGender = value
            do { try context.save() }
            catch {
                debugPrint("Problems with saving UserGender into CoreData - \(error.localizedDescription)")
            }
        } else {
            object?[0].userGender = value
            do { try context.save() }
            catch {
                debugPrint("Problems with saving UserGender into CoreData - \(error.localizedDescription)")
            }
        }
    }
    
    func saveUserBirthday(date: Date) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userBirthday = date
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserBirthday into CoreData - \(error.localizedDescription)")
        }
    }
    
    func saveUserHeight(value: Double) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userHeight = value
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserHeight into CoreData - \(error.localizedDescription)")
        }
    }
    
    func saveUserStartWeight(value: Double) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userStartWeight = value
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserStartWeight into CoreData - \(error.localizedDescription)")
        }
    }
    
    func saveUserGoalWeight(value: Double) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userGoalWeight = value
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserGoalWeight into CoreData - \(error.localizedDescription)")
        }
    }
    
    func saveUserGoal(answer: String) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userGoal = answer
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserGoal into CoreData - \(error.localizedDescription)")
        }
    }
    
    func saveUserWeightFrequency(answer: String) {
        let object = try? context.fetch(DomainUser.fetchRequest())
        object?[0].userWeightFrequency = answer
        do { try context.save() }
        catch {
            debugPrint("Problems with saving UserWeightFrequency into CoreData - \(error.localizedDescription)")
        }
    }
    
    // MARK: - ADDING MEASUREMENTS
    func addHipMeasurement(value: Double) {
        let hipMeasurement = HipMeasurement(context: context)
        
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let currentStringDate = formatter.string(from: currentDate)
        let finalDate = formatter.date(from: currentStringDate)
        
        hipMeasurement.hip = value
        hipMeasurement.date = finalDate ?? Date()
        
        do { try context.save() }
        catch {
            debugPrint("Problems with saving hip size into CoreData - \(error.localizedDescription)")
        }
    }
    
    func addWaistMeasurement(value: Double) {
        let waistMeasurement = WaistMeasurement(context: context)
        
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let currentStringDate = formatter.string(from: currentDate)
        let finalDate = formatter.date(from: currentStringDate)
        
        waistMeasurement.waist = value
        waistMeasurement.date = finalDate ?? Date()
        
        do { try context.save() }
        catch {
            debugPrint("Problems with saving waist size into CoreData - \(error.localizedDescription)")
        }
    }
    
    func addChestMeasurement(value: Double) {
        let chestMeasurement = ChestMeasurement(context: context)
        
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let currentStringDate = formatter.string(from: currentDate)
        let finalDate = formatter.date(from: currentStringDate)
        
        chestMeasurement.chest = value
        chestMeasurement.date = finalDate ?? Date()
        
        do { try context.save() }
        catch {
            debugPrint("Problems with saving chest size into CoreData - \(error.localizedDescription)")
        }
    }
    
    func addWeightMeasurement(value: Double) {
        let weightMeasurement = WeightMeasurement(context: context)
        
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let currentStringDate = formatter.string(from: currentDate)
        let finalDate = formatter.date(from: currentStringDate)
        
        weightMeasurement.weight = value
        weightMeasurement.date = finalDate ?? Date()
        weightMeasurement.preciseDate = Date()
        
        do { try context.save() }
        catch {
            debugPrint("Problems with saving weight into CoreData - \(error.localizedDescription)")
        }
    }
    
    //MARK: - DELETE MEASUREMENTS
    func deleteWeightMeasurement(indexPath: Int) {
        guard let weightMeasurement = try? context.fetch(WeightMeasurement.fetchRequest()) else { return }
        let index = weightMeasurement.count - indexPath - 1
        context.delete(weightMeasurement[index])
        do { try context.save() }
        catch {
            debugPrint("Problems with deleting WeightMeasurement from CoreData - \(error.localizedDescription)")
        }
    }
    
    func deleteHipMeasurement(indexPath: Int) {
        guard let hipMeasurement = try? context.fetch(HipMeasurement.fetchRequest()) else { return }
        let index = hipMeasurement.count - indexPath - 1
        context.delete(hipMeasurement[index])
        do { try context.save() }
        catch {
            debugPrint("Problems with deleting HipMeasurement from CoreData - \(error.localizedDescription)")
        }
    }
    
    func deleteChestMeasurement(indexPath: Int) {
        guard let chestMeasurement = try? context.fetch(ChestMeasurement.fetchRequest()) else { return }
        let index = chestMeasurement.count - indexPath - 1
        context.delete(chestMeasurement[index])
        do { try context.save() }
        catch {
            debugPrint("Problems with deleting HipMeasurement from CoreData - \(error.localizedDescription)")
        }
    }
    
    func deleteWaistMeasurement(indexPath: Int) {
        guard let waistMeasurement = try? context.fetch(WaistMeasurement.fetchRequest()) else { return }
        let index = waistMeasurement.count - indexPath - 1
        context.delete(waistMeasurement[index])
        do { try context.save() }
        catch {
            debugPrint("Problems with deleting HipDimension from CoreData - \(error.localizedDescription)")
        }
    }
    
    //MARK: - FETCHING DATA FROM DB
    private func fetchData<T: NSManagedObject>(from entity: T.Type, period: Int, completion: (Result<[NSFetchRequestResult], Error>) -> Void) {
        do{
            let request = entity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            let oneDay = -86400
            let currentDate = Date()
            let lastDate = Date(timeIntervalSinceNow: TimeInterval(period * oneDay))
            
            let predicate = NSPredicate(format: "date >= %@ AND date <= %@", lastDate as NSDate, currentDate as NSDate)
            request.predicate = predicate
            
            let dimensions = try context.fetch(request)
            completion(.success(dimensions))
        }
        catch {
            completion(.failure(CDError.fetchingError(error: error.localizedDescription)))
            debugPrint("Problems with fetching \(entity.description()) from CoreData - \(error.localizedDescription)")
        }
        
    }
    
    private func fetchAllData<T: NSManagedObject>(from entity: T.Type, completion: (Result<[T], CDError>) -> Void) {
        do{
            let request = entity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dimensions = try context.fetch(request)
            guard let dimensions = dimensions as? [T] else {
                completion(.failure(.fetchingError(error: "Can't cast dimensions of type \(String(describing: entity))")))
                return
            }
            completion(.success(dimensions))
        }
        catch {
            completion(.failure(CDError.fetchingError(error: error.localizedDescription)))
            debugPrint("Problems with fetching \(entity.description()) from CoreData - \(error.localizedDescription)")
        }
    }
    
    private func fetchLastDimension<T: NSManagedObject>(from entity: T.Type, completion: (Result<T, CDError>) -> Void) {
        do{
            let request = entity.fetchRequest()
            guard let dimensions = try context.fetch(request).last as? T else {
                completion(.failure(.fetchingError(error: "Can't cast dimensions of type \(String(describing: entity))")))
                return
            }
            completion(.success(dimensions))
        }
        catch {
            completion(.failure(CDError.fetchingError(error: error.localizedDescription)))
            debugPrint("Problems with fetching \(entity.description()) from CoreData - \(error.localizedDescription)")
        }
    }
    
    func fetchDomainUserInfo(completion: (Result<DomainUser, Error>) -> Void) {
        do{
            let object = try context.fetch(DomainUser.fetchRequest())
            let firstUserInfo = object[0]
            completion(.success(firstUserInfo))
        }
        catch {
            completion(.failure(CDError.fetchingError(error: error.localizedDescription)))
            debugPrint("Problems with fetching FirstUserInfo from CoreData - \(error.localizedDescription)")
        }
    }
    
    func fetchAllDimensions<T: NSManagedObject>(measurementType: MeasurementTypes, completion: (Result<[T], CDError>) -> Void) {
        let type: T.Type = {
            switch measurementType {
            case .chest:
                return ChestMeasurement.self as! T.Type
            case .waist:
                return WaistMeasurement.self as! T.Type
            case .hip:
                return HipMeasurement.self as! T.Type
            case .weight:
                return WeightMeasurement.self as! T.Type
            case .bmi:
                return WeightMeasurement.self as! T.Type
            }
        }()
        switch measurementType {
        case .chest:
            fetchAllData(from: type, completion: completion)
        case .waist:
            fetchAllData(from: type, completion: completion)
        case .hip:
            fetchAllData(from: type, completion: completion)
        case .weight:
            fetchAllData(from: type, completion: completion)
        case .bmi: return
        }
    }
    
    func fetchLastDimension<T: NSManagedObject>(measurementType: MeasurementTypes, completion: (Result<T, CDError>) -> Void) {
        let type: T.Type = {
            switch measurementType {
            case .chest:
                return ChestMeasurement.self as! T.Type
            case .waist:
                return WaistMeasurement.self as! T.Type
            case .hip:
                return HipMeasurement.self as! T.Type
            case .weight:
                return WeightMeasurement.self as! T.Type
            case .bmi:
                return WeightMeasurement.self as! T.Type
            }
        }()
        switch measurementType {
        case .chest:
            fetchLastDimension(from: type, completion: completion)
        case .waist:
            fetchLastDimension(from: type, completion: completion)
        case .hip:
            fetchLastDimension(from: type, completion: completion)
        case .weight:
            fetchLastDimension(from: type, completion: completion)
        case .bmi: return
        }
    }
    
    func fetchDimensions(measurementType: MeasurementTypes, period: Int, completion: (Result<[NSFetchRequestResult], Error>) -> Void) {
        switch measurementType {
        case .chest:
            fetchData(from: ChestMeasurement.self, period: period, completion: completion)
        case .waist:
            fetchData(from: WaistMeasurement.self, period: period, completion: completion)
        case .hip:
            fetchData(from: HipMeasurement.self, period: period, completion: completion)
        case .weight:
            fetchData(from: WeightMeasurement.self, period: period, completion: completion)
        case .bmi:
            fetchData(from: WeightMeasurement.self, period: period, completion: completion)
        }
    }

    
//    func deleteSpecificRecord(sample: MeasurementSample) {
//        formatter.dateFormat = "dd.MM.yyyy"
//        fetchAllDimensions(for: .weight) { result in
//            switch result {
//            case .success(let measurements):
//                guard
//                    let measurements = measurements as? [WeightMeasurement],
//                    let objectectToDelete = measurements.first(where:  { measurement in
//                        let sampleDateString = formatter.string(from: sample.date)
//                        let measurementDateString = formatter.string(from: measurement.date)
//                        return sampleDateString == measurementDateString
//                    })
//                else { return }
//                print("Object to delete \(objectToDelete.date)")
//                context.delete(objectToDelete)
//                do {
//                    try context.save()
//                } catch let error {
//                    print(error)
//                }
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
}



