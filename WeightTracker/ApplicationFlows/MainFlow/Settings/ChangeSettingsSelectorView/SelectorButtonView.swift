//
//  SelectorButtonView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit

final class SelectorButtonView: UIView {
    
    private var titleLabel = UILabel()
    
    var title = ""
    var isSelected = true
    var onViewTapCallback: ((String) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        configureView()
        configureTitleLabel()
        configureViewTapGesture()
    }
    
    // MARK: - ConfigureUI
    private func configureView() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        if isSelected {
            layer.backgroundColor = UIColor.weightPrimary.cgColor
        } else {
            layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    private func configureTitleLabel() {
        titleLabel.font = R.font.openSansMedium(size: 20)
        titleLabel.text = title
        isSelected == true ? (titleLabel.textColor = .white) : (titleLabel.textColor = .weightPrimary)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func onViewTapped() {
        HapticFeedback.medium.vibrate()
        onViewTapCallback?(title)
    }
}
