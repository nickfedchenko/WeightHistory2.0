//
//  ChestMeasurement+CoreDataProperties.swift
//  
//
//  Created by Andrey Alymov on 24.01.2023.
//
//

import Foundation
import CoreData


extension ChestMeasurement: WTGraphRawDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChestMeasurement> {
        return NSFetchRequest<ChestMeasurement>(entityName: "ChestMeasurement")
    }

    @NSManaged public var chest: Double
    @NSManaged public var date: Date
    
    var value: CGFloat {
        self.chest
    }
}
