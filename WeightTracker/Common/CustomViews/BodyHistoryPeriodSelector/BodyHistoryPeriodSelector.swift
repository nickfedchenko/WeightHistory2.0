//
//  BodyHistoryPeriodSelector.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class BodyHistoryPeriodSelector: UIView {
    
    // MARK: - Property list
    private var items: [String] = []
    private var buttons: [UIButton] = []
    private var selectorView = UIView()
    
    private var selectedItemTextColor = UIColor.white
    private var unselectedItemTextColor = UIColor.red
    private var selectedItemViewColor = UIColor.white
    
    var selectorType: MeasurementTypes = .weight
    var isSelectorChanged = false
    var selectedItem = ""
    var isDailyPeriod = true
    var buttonCallback: ((UIButton) -> Void)?
    
    // MARK: - Public methods
    func configure() {
        setupItems()
        configureView()
        updateView()
    }
    
    // MARK: - Configure View
    private func configureView() {
        backgroundColor = selectorType.backgroundColor
        layer.cornerRadius = 8
        configureColors()
    }
    
    private func configureColors() {
        selectedItemTextColor = selectorType.color
        unselectedItemTextColor = selectorType.unselectedItemColor
        selectedItemViewColor = UIColor.white
    }
    
    private func setupItems() {
        items = [
            R.string.localizable.periodsDaily(),
            R.string.localizable.periodsWeekly(),
            R.string.localizable.periodsMonthly()
        ]
    }
    
    private func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview()}
        updateSelectorView()
        
        items.forEach { item in
            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.setTitleColor(unselectedItemTextColor, for: .normal)
            button.titleLabel?.font = R.font.openSansMedium(size: 17)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons.first?.setTitleColor(selectedItemTextColor, for: .normal)
        selectedItem = buttons.first?.titleLabel?.text ?? ""
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.bottom.top.trailing.leading.equalToSuperview()
        }
    }
    
    private func updateSelectorView() {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width - 48
        let selectorWidth = screenWidth / CGFloat(items.count)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: 40))
        
        view.backgroundColor = selectedItemViewColor
        view.layer.borderWidth = 1
        view.layer.borderColor = selectorType.borderColor.cgColor
        
        view.layer.shadowColor = selectorType.color.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.2
        
        view.layer.cornerRadius = 8
        
        selectorView = view
        addSubview(selectorView)
    }
    
    // MARK: - Actions
    @objc func buttonTapped(button: UIButton) {
        HapticFeedback.selection.vibrate()
        isSelectorChanged = true
        buttonCallback?(button)
        
        if button.titleLabel?.text == R.string.localizable.periodsDaily() {
            isDailyPeriod = true
        } else {
            isDailyPeriod = false
        }
        
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(unselectedItemTextColor, for: .normal)
            
            if btn == button {
                selectedItem = btn.titleLabel?.text ?? ""
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = selectorStartPosition
                    button.setTitleColor(self.selectedItemTextColor, for: .normal)
                }
            }
        }
    }
}
