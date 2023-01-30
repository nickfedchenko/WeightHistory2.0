//
//  GoalsSegmentView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class GoalsSegmentView: UIView {
    
    // MARK: - Property list
    private var milestoneNumbersLabel = UILabel()
    private var squareView = UIView()
    private var arrowImageView = UIImageView()
    
    var onMilestoneSegmentPressed: (() -> Void)?
    var isStateOn = true {
        didSet {
            configureView()
            configureArrowImageView()
        }
    }
    
    // MARK: - Publick configure
    func configure(milestones: Int) {
        configureUI()
        configureMilestoneNumbersLabel(milestones: milestones)
        configureView()
        configureViewTapGesture()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureSquareView()
        configureArrowImageView()
    }
    
    private func addSubViews() {
        addSubview(milestoneNumbersLabel)
        addSubview(squareView)
        squareView.addSubview(arrowImageView)
    }
    
    private func configureMilestoneNumbersLabel(milestones: Int) {
        milestoneNumbersLabel.attributedText = NSMutableAttributedString(string: String(milestones), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansBold(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.white.cgColor
        ])
    }
    
    private func configureView() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        if isStateOn {
            layer.backgroundColor = UIColor.weightPrimary.cgColor
            isUserInteractionEnabled = true
        } else {
            layer.backgroundColor = UIColor.milestoneUnselectedColor.cgColor
            isUserInteractionEnabled = false
        }
    }
    
    private func configureSquareView() {
        squareView.layer.cornerRadius = 6
        squareView.layer.cornerCurve = .continuous
        squareView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    private func configureArrowImageView() {
        if isStateOn {
            arrowImageView.image = R.image.arrowDown()
        } else {
            arrowImageView.image = R.image.arrowDownUnselected()
        }
    }
    
    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMilestoneSegmentTapped))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func onMilestoneSegmentTapped() {
        onMilestoneSegmentPressed?()
    }
}

// MARK: - Setup cpnstraints
extension GoalsSegmentView {
    
    private func setupConstraints() {
        
        milestoneNumbersLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        squareView.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(28)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(2)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.height.equalTo(9)
            make.width.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)

        }
    }
}
