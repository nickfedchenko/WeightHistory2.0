//
//  DomainUser+CoreDataProperties.swift
//  
//
//  Created by Andrey Alymov on 24.01.2023.
//
//

import Foundation
import CoreData


extension DomainUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DomainUser> {
        return NSFetchRequest<DomainUser>(entityName: "DomainUser")
    }

    @NSManaged public var userBirthday: Date?
    @NSManaged public var userGender: Int16
    @NSManaged public var userGoal: String?
    @NSManaged public var userGoalWeight: Double
    @NSManaged public var userHeight: Double
    @NSManaged public var userStartWeight: Double
    @NSManaged public var userWeightFrequency: String?
    
    var userGenderString: String {
        self.userGender == 1 ? R.string.localizable.onboardingGenderMale() : R.string.localizable.onboardingGenderFemale()
    }

}
