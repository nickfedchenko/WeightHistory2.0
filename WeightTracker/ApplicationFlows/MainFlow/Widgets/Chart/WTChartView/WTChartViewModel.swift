//
//  WTChartViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

protocol WTGraphRawDataModel {
    var value: CGFloat { get }
    var date: Date { get }
}

extension WTGraphRawDataModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(date)
    }
}

final class WTChartViewModel {
    
    // Chart drawing model
    struct WTChartDrawInstructions {
        
        struct OuterContainerData {
            let timeValues: [String]
            let values: [CGFloat]
        }
        
        struct DrawingData {
            // center cgpoint
            var controlPoints: [CGPoint]
            let verticalInset: CGFloat
            let horizontalInset: CGFloat
            let hAxisYcoordinates: [CGFloat]
            let vAxisXcoordinates: [CGFloat]
            let hAxisWidth: CGFloat
            let vAxisHeight: CGFloat
            let color: UIColor
        }
        
        let outerContainerData: OuterContainerData
        let innerContainerDrawingData: DrawingData
    }
    
    // Periods type
    enum WTChartPeriod: Int, CaseIterable {
        case week = 7
        case month = 1
        case twoMonth = 2
        case threeMonth = 3
        case sixMonth = 6
        case year = 12
//        case allTime = 0
        
        var buttonTitle: String {
            switch self {
            case .week:
                return R.string.localizable.periodsWeek().capitalized
            case .month:
                return R.string.localizable.periodsMonth()
            case .twoMonth:
                return R.string.localizable.periodsTwoMonths()
            case .threeMonth:
                return R.string.localizable.periodsThreeMonths()
            case .sixMonth:
                return R.string.localizable.periodsSixMonths()
            case .year:
                return R.string.localizable.periodsYear()
//            case .allTime:
//                return "All time"
            }
        }
        
        var days: Int {
            switch self {
            case .week:
                return 7
            case .month:
                return 30
            case .twoMonth:
                return 60
            case .threeMonth:
                return 90
            case .sixMonth:
                return 180
            case .year:
                return 365
            }
        }
    }
    
    // Chart modes type
    public enum WTChartMode: String, CaseIterable {
        case weight = "Weight"
        case bmi = "BMI"
        case chest = "Chest"
        case waist = "Waist"
        case hip = "Hip"
        
        var dominantColor: UIColor {
            switch self {
            case .hip:
                return .hipMeasurementColor
            case .waist:
                return .waistMeasurementColor
            case .chest:
                return .chestMeasurementColor
            case .weight:
                return .weightMeasurementColor
            case .bmi:
                return .bmiMainColor
            }
        }
        
        var measurementType: MeasurementTypes {
            switch self {
            case .weight:   return .weight
            case .bmi:      return .bmi
            case .chest:    return .chest
            case .waist:    return .waist
            case .hip:      return .hip
            }
        }
    }
    
    var mode: WTChartMode = .weight
    var period: WTChartPeriod = .twoMonth
    var rawData: [any WTGraphRawDataModel] = []
    var innerContainerSizeProvider: (() -> (CGSize, CGFloat, CGFloat))?
    var updateHandler: ((WTChartDrawInstructions) -> Void)?
    var outerContainerHandler: ((WTChartDrawInstructions) -> Void)?
    var setNeedUpdate: Bool = false {
        willSet {
            if newValue {
                updateChartWithProvidedData()
                setNeedUpdate = false
            }
        }
    }
    
    var currentDate: Date = Date()
    
    // MARK: - Init
    init(mode: WTChartMode, period: WTChartPeriod) {
        self.mode = mode
        self.period = period
    }
    
    // MARK: - Publick methods
    func updateChartWithProvidedData()  {
        guard let dimensions = innerContainerSizeProvider?() else { return }
        let dateLabels = makeDateLabelsStringsRanges()
        let values = makesValues(for: dateLabels.dateRange.min, and: dateLabels.dateRange.max)
        let valuesForAxis = makeHorizontalAxisValues(for: values)
        let controlPoints = generateControlPoints(for: values, with: valuesForAxis, dates: dateLabels.dateRange)
        let hAxisYCoordinates: [CGFloat] = makeHAxisYControlPoints(for: valuesForAxis)
        let vAxisXCoordinates: [CGFloat] = makeVAxisXControlPoints(for: dateLabels.labels)
        
        let instructions = WTChartDrawInstructions(
            outerContainerData: .init(
                timeValues: dateLabels.labels,
                values: valuesForAxis
            ),
            innerContainerDrawingData: .init(
                controlPoints: controlPoints,
                verticalInset: dimensions.1,
                horizontalInset: dimensions.2,
                hAxisYcoordinates: hAxisYCoordinates,
                vAxisXcoordinates: vAxisXCoordinates,
                hAxisWidth: dimensions.0.width,
                vAxisHeight: dimensions.0.height,
                color: mode.dominantColor
            )
        )
        updateHandler?(instructions)
        outerContainerHandler?(instructions)
    }
    
    // MARK: - Private methods
    private func makeHAxisYControlPoints(for valuesForAxis: [CGFloat] ) -> [CGFloat] {
        guard let dimensions = innerContainerSizeProvider?() else { return [] }
        var hAxisYCoordinates: [CGFloat] = []
        let rowsCount: CGFloat = mode == .weight ? 5 : 3
        let strideForHAxis = (dimensions.0.height - (dimensions.1 * 2)) / rowsCount
        for (index, _) in valuesForAxis.enumerated() {
            let yCoordinate = CGFloat(index) * strideForHAxis + dimensions.1
            hAxisYCoordinates.append(yCoordinate)
        }
        return hAxisYCoordinates
    }
    
    private func makeVAxisXControlPoints(for dateLabels: [String]) -> [CGFloat] {
        guard let dimensions = innerContainerSizeProvider?() else { return [] }
        var vAxisXCoordinates: [CGFloat] = []
        let strideForYAxis = (dimensions.0.width - (dimensions.2 * 2)) / 6
        for (index, _) in dateLabels.enumerated() {
            let xCoordinate = CGFloat(index) * strideForYAxis + dimensions.2
            vAxisXCoordinates.append(xCoordinate)
        }
        return vAxisXCoordinates
    }
    
    private func generateControlPoints(
        for values: [WTGraphRawDataModel],
        with axisValues: [CGFloat],
        dates range: (min: Date, max: Date)
    ) -> [CGPoint] {
        guard
            let dimensions = innerContainerSizeProvider?(),
            dimensions.0 != .zero else {
            return []
        }
        guard values.count > 1 else {
            return [CGPoint(x: dimensions.0.width - dimensions.2, y: dimensions.1)]
        }
        let size = dimensions.0
        let verticalInsets = dimensions.1
        let horizontalInsets = dimensions.2
        let min = axisValues.min() ?? 0
        let max = axisValues.max() ?? 0
        let minDate = range.min
        let maxDate = range.max
        let distance = CGFloat(Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0)
        let valueRange = (max - min)
        let height = size.height
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return values.sorted{ $0.date > $1.date}.map { model in
            
            let currentDistance = distance - CGFloat(Calendar.current.dateComponents([.day], from: model.date, to: maxDate).day ?? 0)
            let hRatio = currentDistance / distance
            let xCoordinate = (size.width - (horizontalInsets * 2)) * hRatio + horizontalInsets
            let vRatio = (max - model.value) / valueRange
            let yCoordinate = (height - (verticalInsets * 2)) * vRatio + verticalInsets
            return CGPoint(x: xCoordinate, y: yCoordinate)
        }
    }
        
    private func makesValues(for minDate: Date, and maxDate: Date) -> [WTGraphRawDataModel] {
        guard rawData.count > 7 else {
            let values = rawData.sorted { $0.date < $1.date }
            return values
        }
        var stride = 0
       
        switch period {
        case .week:
            stride = 1
        case .month:
            stride = 1
        case .twoMonth:
            stride = 2
        case .threeMonth:
            stride = 2
        case .sixMonth:
            stride = 5
        case .year:
            stride = 2
//        case .allTime:
//            stride = rawData.count / 15
        }
        
        let rawSortedByDate = rawData
            .sorted(by: { $0.date < $1.date})
        
        let values = rawSortedByDate.filter { (minDate...maxDate).contains($0.date)}
            .enumerated()
            .compactMap { index, model in
                if index % stride == 0 {
                    return model
                } else {
                    return nil
                }
            }
        return values
    }
    
    private func makeHorizontalAxisValues(for rawData: [WTGraphRawDataModel]) -> [CGFloat] {
        guard !rawData.isEmpty else {
            return mode == .weight
            ? [84, 83, 82, 81, 80, 79]
            : [50, 49, 48, 47]
        }
        
        guard rawData.count != 1 else {
            let value = rawData[0].value
            return mode == .weight
            ? [value, value - 1, value - 2, value - 3, value - 4, value - 5]
            : [value, value - 1, value - 2, value - 3]
        }
        
        let values = rawData.map { $0.value }
        
        guard
            let max = values.max(),
            let min = values.min() else {
            return mode == .weight
            ? [84, 83, 82, 81, 80, 79]
            : [50, 49, 48, 47]
        }
        
        guard max - min >= 5 else {
            return mode == .weight
            ? [max, max - 1, max - 2, max - 3, max - 4, max - 5]
            : [max, max - 1, max - 2, max - 3]
        }
        
        var stride = (max - min) / (mode == .weight ? 5 : 3 )
        
        if stride < 1 {
            stride = 1
        }
        
        let valuesForAxis = mode == .weight
        ? [max, max - stride, max - (stride * 2), max - (stride * 3), max - (stride * 4), max - (stride * 5)]
        : [max, max - stride, max - (stride * 2), max - (stride * 3)]
        return valuesForAxis
    }
    
    private func makeDateLabelsStringsRanges() -> (labels: [String], dateRange: (min: Date, max: Date)) {
        let formatter = DateFormatter()
        var stride = 0
        switch period {
        case .week:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: -6, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "dd.MM"
        case .month:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "dd.MM"
        case .twoMonth:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .month, value: -2, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "dd.MM"
        case .threeMonth:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .month, value: -3, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "dd.MM"
        case .sixMonth:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .month, value: -6, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "dd.MM"
        case .year:
            let distance = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .year, value: -1, to: currentDate) ?? Date(), to: currentDate).day ?? 0
            stride = distance / 6
            formatter.dateFormat = "MMM"
//        case .allTime:
//            let distance = Calendar.current.dateComponents([.month], from: rawData.last?.date ?? Date(), to: Date()).day ?? 0
//            stride = distance / 6
//            if stride < 1 {
//                stride = 1
//            }
//            formatter.dateFormat = "MM.yyyy"
        }
        if stride == 0 {
            stride = 1
        }
        
        let labels = sequence(first: 0) {
            if $0 + stride > stride * 6 {
                return nil
            } else {
                return  $0 + stride
            }
        }
            .compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: currentDate) }
            .sorted(by: <)
            .map { formatter.string(from: $0) }
        let dates = sequence(first: 0) {
            if $0 + stride > stride * 6 {
                return nil
            } else {
                return  $0 + stride
            }
        }
            .compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: currentDate) }
            .sorted(by: <)
        guard
            let minDate = dates.first,
            let maxDate = dates.last
        else {
            return (labels: labels, dateRange: (min: Date(), max: Date()))
        }
        return (labels, (minDate, maxDate))
    }
}
