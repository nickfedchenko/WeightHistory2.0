//
//  PaywallViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import ApphudSDK
import Foundation

final class SubscriptionViewModel {
    
    // MARK: - Property list
    private let userSettingsService = UserSettingsService.shared
    private let dbService = CoreDataService.shared
    
    var benefitCells: [String] = []
    private var products: [ApphudProduct] = [] {
        didSet {
            reloadHandler?()
        }
    }
    var reloadHandler: (() -> Void)?
    var selectedIndex = 0
    
    // MARK: - Init
    init() {
        makeBenifitCells()
        onboardingWillNotShowingMore()
        isUserSplitGoal()
        addFirstWeightMeasurement()
    }
    
    // MARK: - MAKE BENIFIT CELLS
    private func makeBenifitCells() {
        benefitCells = [
            R.string.localizable.subscriptionBenefitsControlWeight(),
            R.string.localizable.subscriptionBenefitsMeasure(),
            R.string.localizable.subscriptionBenefitsMonitor(),
            R.string.localizable.subscriptionBenefitsBreakGoals()
        ]
    }
    
    // MARK: - USER SETTINGS
    private func onboardingWillNotShowingMore() {
        userSettingsService.onboardingWillNotShowingMore()
    }
    
    private func isUserSplitGoal() {
        userSettingsService.setIsUserSplitGoal(value: true)
    }
    
    // MARK: - APPHUD
    func loadProducts() {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let products = paywalls.first?.products   else { return }
            self?.products = products
        }
    }
    
    func getProductToPurchase() -> ApphudProduct? {
        guard !products.isEmpty else {
            return nil
        }
        return products[selectedIndex]
    }
    
    func numberOfProducts() -> Int {
        guard !products.isEmpty else { return 3 }
        return products.count
    }
    
    func makeModelForProduct(at indexPath: IndexPath) -> PayCellModel {
        guard !products.isEmpty else {
            return .init(periodTitle: "Loading info", priceString: "", weeklyPriceString: "Loading")
        }
        let product = products[indexPath.item]
        let periodTitle = makePeriodStirng(for: product)
        let priceString = makePriceString(for: product)
        let weeklyPriceString = makeWeeklyPrice(for: product)
        return .init(periodTitle: periodTitle, priceString: priceString, weeklyPriceString: weeklyPriceString)
    }
    
    private func makePeriodStirng(for product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct else {
            return "Loading info"
        }
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return R.string.localizable.subscriptionAnnual()
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return R.string.localizable.subscriptionMonthly()
            } else {
                return "Error fetching payment info"
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return R.string.localizable.subscriptionWeekly()
            } else {
                return "Error fetching payment info"
            }
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return R.string.localizable.subscriptionWeekly()
            } else {
                return "Error fetching payment info"
            }
        default:
            return "Error fetching payment info"
        }
    }
    
    func makePriceString(for product: ApphudProduct) -> String {
        guard
            let skProduct = product.skProduct,
            let currencySymbol = skProduct.priceLocale.currencySymbol
        else {
            return ""
        }
        let price = skProduct.price.doubleValue
        
        
        let shouldTruncate = price.truncatingRemainder(dividingBy: 1) > 0 ? false : true
        let priceString = currencySymbol + (shouldTruncate ? String(format: "%.0f", price) : String(format: "%.2f", price))
        return priceString
    }
    
    func makeWeeklyPrice(for product: ApphudProduct) -> String {
        guard
            let skProduct = product.skProduct,
            let currencySymbol = skProduct.priceLocale.currencySymbol
        else {
            return ""
        }
        let price = skProduct.price.doubleValue
        var string = ""
        var weeklyPrice: Double = 0
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            weeklyPrice = price / 52
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                weeklyPrice = price
            }
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                weeklyPrice = price
            }
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                weeklyPrice = price / 4.34
            }
        default:
           return ""
        }
        let shouldTruncate = weeklyPrice.truncatingRemainder(dividingBy: 1) > 0 ? false : true
        string = currencySymbol + (shouldTruncate ? String(format: "%.0f", weeklyPrice) : String(format: "%.2f", weeklyPrice))
        return string
    }
    
    // MARK: - ADDING FIRST WEIGHT VALUE
    func addFirstWeightMeasurement() {
        var isWeightMeasurementsEmpty = true
        dbService.fetchAllMeasurements(measurementType: .weight) { res in
            switch res {
            case .success(let success):
                isWeightMeasurementsEmpty = success.isEmpty
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        if isWeightMeasurementsEmpty {
            dbService.fetchDomainUserInfo { res in
                switch res {
                case .success(let success):
                    dbService.addWeightMeasurement(value: success.userStartWeight)
                case .failure(let failure):
                    debugPrint(failure)
                }
            }
        }
    }
}
