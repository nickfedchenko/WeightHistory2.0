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
    private let widgetSizeService = WidgetSizeService(type: .medium)
    private let facade: DataProviderServiceProtocol = DataProviderService.shared
    
    // MARK: - Public methods
    func getDateLabel(completion: @escaping (String) -> Void) {
        let formatter = DateFormatter()
        if Locale.isLanguageRus {
            formatter.dateFormat = "d MMMM"
        } else {
            formatter.dateFormat = "MMM d"
        }
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
        }
    }
    
    func getWidgetHeight() -> CGFloat {
        return widgetSizeService.height
    }
    
    func getWidgetWidth() -> CGFloat {
        return widgetSizeService.widgetWidth
    }
}
