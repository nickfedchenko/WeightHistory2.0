//
//  WTChartPeriodSelectorButton.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartPeriodSelectorButton: UIButton {
    
    // MARK: - Properties
    private var modeColor: UIColor
    var mode: WTChartViewModel.WTChartMode
    var period: WTChartViewModel.WTChartPeriod
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setSelected()
            } else {
                setDeselected()
            }
        }
    }
    
    // MARK: - Init
    init(with mode: WTChartViewModel.WTChartMode, period: WTChartViewModel.WTChartPeriod ) {
        modeColor = mode.dominantColor
        self.mode = mode
        self.period = period
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setSelected() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = self.modeColor
            self.titleLabel?.textColor = .white
        }
    }
    
    private func setDeselected() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .clear
            self.titleLabel?.textColor = self.modeColor
        }
    }
}
