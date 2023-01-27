//
//  HipMeasurement+CoreDataProperties.swift
//  
//
//  Created by Andrey Alymov on 24.01.2023.
//
//

import Foundation
import CoreData


extension HipMeasurement: WTGraphRawDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HipMeasurement> {
        return NSFetchRequest<HipMeasurement>(entityName: "HipMeasurement")
    }

    @NSManaged public var hip: Double
    @NSManaged public var date: Date

    var value: CGFloat {
        self.hip
    }
}
