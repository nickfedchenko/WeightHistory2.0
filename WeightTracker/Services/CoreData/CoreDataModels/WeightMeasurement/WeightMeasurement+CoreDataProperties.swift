//
//  WeightMeasurement+CoreDataProperties.swift
//  
//
//  Created by Andrey Alymov on 24.01.2023.
//
//

import Foundation
import CoreData


extension WeightMeasurement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightMeasurement> {
        return NSFetchRequest<WeightMeasurement>(entityName: "WeightMeasurement")
    }

    @NSManaged public var date: Date
    @NSManaged public var preciseDate: Date
    @NSManaged public var weight: Double
    
    var value: CGFloat {
        self.weight
    }
}
