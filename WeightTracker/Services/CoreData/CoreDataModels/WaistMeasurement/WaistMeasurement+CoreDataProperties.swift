//
//  WaistMeasurement+CoreDataProperties.swift
//  
//
//  Created by Andrey Alymov on 24.01.2023.
//
//

import Foundation
import CoreData


extension WaistMeasurement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaistMeasurement> {
        return NSFetchRequest<WaistMeasurement>(entityName: "WaistMeasurement")
    }

    @NSManaged public var date: Date
    @NSManaged public var waist: Double
    
    var value: CGFloat {
        self.waist
    }
}
