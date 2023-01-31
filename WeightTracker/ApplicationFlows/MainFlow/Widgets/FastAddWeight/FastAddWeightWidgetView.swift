//
//  FastAddWeightWidgetView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class FastAddWeightWidgetView: UIView {
    
    // MARK: - Property list
    private var addButton = ActionButton()
    var onWidgetPressed: (() -> Void)?
    
    // MARK: - Configuration
    func configure() {
        configureUI()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureAddButton()
    }
    
    private func addSubViews() {
        addSubview(addButton)
    }
    
    // MARK: - ADD BUTTON
    private func configureAddButton() {
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        addButton.makeMainState()
        addButton.setImage(R.image.plus(), for: .normal)
    }
    
    @objc private func addButtonPressed() {
        HapticFeedback.heavy.vibrate()
        onWidgetPressed?()
    }
}

// MARK: - Setup cpnstraints
extension FastAddWeightWidgetView {
    
    private func setupConstraints() {
        addButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

