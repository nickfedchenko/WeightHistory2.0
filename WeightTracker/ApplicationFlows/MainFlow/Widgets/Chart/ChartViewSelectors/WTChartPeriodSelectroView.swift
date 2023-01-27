//
//  WTChartPeriodSelectroView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartPeriodSelectorView: UIView {
    
    // MARK: - Properties
    var periodTappeddAction: (() -> Void)?
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.chevronUp(), for: .normal)
        button.layer.cornerRadius = 4
        button.tintColor = WTChartViewModel.WTChartMode.weight.dominantColor
        return button
    }()
    
    let label = WTChartPeriodSelectorShadowLabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupActions()
        label.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Publick methods
    func updateColor(for mode: WTChartViewModel.WTChartMode) {
        chevronButton.tintColor = mode.dominantColor
        label.setNewTextColor(color: mode.dominantColor)
    }
    
    // MARK: - ANIMATION
    private func animateTapHighlighted() {
        UIView.animate(withDuration: 0.3) {
            self.label.alpha = 0.4
            self.chevronButton.alpha = 0.4
        }
    }
    
    private func animateTapNonHighlighted () {
        UIView.animate(withDuration: 0.3) {
            self.label.alpha = 1
            self.chevronButton.alpha = 1
        }
    }
    
    // MARK: - ACTIONS
    private func setupActions() {
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))
        longTapGesture.minimumPressDuration = 0.1
        label.addGestureRecognizer(longTapGesture)
        let chevronTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))
        chevronTapRecognizer.minimumPressDuration = 0.1
        chevronButton.addGestureRecognizer(chevronTapRecognizer)
    }
    
    @objc private func labelTapped(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            animateTapHighlighted()
            periodTappeddAction?()
        case .ended:
            animateTapNonHighlighted()
        case .cancelled:
            animateTapNonHighlighted()
        case .changed:
            animateTapHighlighted()
            
        default:
            animateTapNonHighlighted()
        }
    }
    
    // MARK: - Setup subviews
    private func setupSubviews() {
        addSubview(chevronButton)
        addSubview(label)
        
        chevronButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(1)
        }
        
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview()
        }
    }
    
}
