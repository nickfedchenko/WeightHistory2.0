//
//  CoreDataError.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import Foundation

enum CDError: Error {
    case fetchingError(error: String)
}
