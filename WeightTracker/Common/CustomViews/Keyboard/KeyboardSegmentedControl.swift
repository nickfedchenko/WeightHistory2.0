//
//  KeyboardSegmentedControl.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class KeyboardSegmentedControl: UIView {
    
    //MARK: - Property list
    private var items: [String] = []
    private var buttons: [UIButton] = []
    private var selectorView = UIView()
    
    private var selectedItemTextColor = UIColor.white
    private var unselectedItemTextColor = UIColor.white
    private var selectedItemViewColor = UIColor.white
    private var type: Units = .height
    
    var buttonCallback: ((UIButton) -> Void)?
    
    //MARK: - Public methods
    func configure(for unit: Units) {
        type = unit
        setupItems()
        configureView()
        updateView()
    }
    
    //MARK: - Private methods
    private func configureView() {
        backgroundColor = .keyboardButtonsBackgroundColor
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        configureColors()
    }
    
    private func configureColors() {
        selectedItemTextColor = .keyboardButtonsSelectedTextColor
        unselectedItemTextColor = .keyboardButtonsUnselectedTextColor
        selectedItemViewColor = .keyboardButtonsSelectedItemColor
    }
    
    private func setupItems() {
        switch type {
        case .height:
            items = [
                R.string.localizable.unitsCm(),
                R.string.localizable.unitsFt()
            ]
        case .weight:
            items = [
                R.string.localizable.unitsKg(),
                R.string.localizable.unitsLbs()
            ]
        }
    }
    
    private func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview()}
        updateSelectorView()
        
        items.forEach { item in
            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.setTitleColor(unselectedItemTextColor, for: .normal)
            button.titleLabel?.font = R.font.openSansSemiBold(size: 20)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons.first?.setTitleColor(selectedItemTextColor, for: .normal)
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
        let screenWidth = UIScreen.main.bounds
        let backgroundViewWidth = screenWidth.size.width - 169
        let selectorWidth = (backgroundViewWidth - 4) / CGFloat(items.count)
        
        let view = UIView(frame: CGRect(x: 2, y: 2, width: selectorWidth, height: 60))
        
        view.backgroundColor = selectedItemViewColor
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        
        selectorView = view
        addSubview(selectorView)
    }
    
    //MARK: - Actions
    @objc func buttonTapped(button: UIButton) {
        HapticFeedback.selection.vibrate()
        buttonCallback?(button)
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(unselectedItemTextColor, for: .normal)
            if btn == button {
                let selectorStartPosition = (frame.width - 4) / CGFloat(buttons.count) * CGFloat(buttonIndex) + 2
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = selectorStartPosition
                    button.setTitleColor(self.selectedItemTextColor, for: .normal)
                }
            }
        }
    }
}
