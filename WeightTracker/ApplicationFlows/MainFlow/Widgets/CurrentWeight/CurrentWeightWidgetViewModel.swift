//
//  CurrentWeightWidgetViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import Foundation

final class CurrentWeightWidgetViewModel {
    
    // MARK: - Property list
    private let dbService = CoreDataService.shared
    private let widgetSize = WidgetSizeService(type: .medium)
    let facade: DataProviderServiceProtocol = DataProviderService.shared
    
    // MARK: - Public methods
    func getDateLabel(completion: @escaping (String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        facade.fetchLastWeight { sample in
            let dateString = formatter.string(from: sample.date)
            completion(dateString)
        }
    }
    
    func getWeightLabel(completion: @escaping (String) -> Void) {
        facade.fetchLastWeight { sample in
            let weightString = "\(String(format: "%.1f", sample.doubleValue)) "
            if weightString == "" {
                completion("0")
            } else {
                completion(weightString)
            }
            print("weight string is \(weightString)")
        }
    }
    
    func getWidgetHeight() -> CGFloat {
        return widgetSize.height
    }
    
    func getWidgetWidth() -> CGFloat {
        return widgetSize.widgetWidth
    }
}
