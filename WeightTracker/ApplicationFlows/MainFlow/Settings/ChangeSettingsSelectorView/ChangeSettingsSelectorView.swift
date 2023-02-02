//
//  ChangeSettingsSelectorView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit

enum SettingsSelectorType {
    case userGender
    case units
    case userGoal
}

final class ChangeSettingsSelectorView: UIView {
    
    // MARK: - Property list
    private var blackoutBackgroundContainer = UIView()
    private var mainViewContainer = UIView()
    private var titleLabel = UILabel()
    private var buttonsStuckView = UIStackView()
    private var yPos: CGFloat = 0
    
    private var selectorType: SettingsSelectorType = .userGender
    private var selectedValue = ""
    
    private var buttonTitles: [String] = []
    
    var selectedValueCallback: ((String, SettingsSelectorType) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(yPos: CGFloat, title: String, selectedValue: String) {
        super.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.yPos = yPos
        self.selectedValue = selectedValue
        configureUI()
        configureTitleLabel(with: title)
        makeSelectorState(with: title)
        makeButtonTitles()
        configureButtonsStackView()
        mainViewContainer.popIn(duration: 0.1)
        configureViewTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
    }
    
    private func addSubViews() {
        addSubview(blackoutBackgroundContainer)
        addSubview(mainViewContainer)
        mainViewContainer.addSubview(titleLabel)
        mainViewContainer.addSubview(buttonsStuckView)
    }
    
    private func configureView() {
        backgroundColor = .clear
        blackoutBackgroundContainer.layer.backgroundColor = UIColor.blackoutBackground.cgColor
        mainViewContainer.layer.backgroundColor = UIColor.mainBackground.cgColor
        mainViewContainer.layer.cornerRadius = 16
        mainViewContainer.layer.cornerCurve = .continuous
        mainViewContainer.layer.shadowColor = UIColor.buttonShadowColor.cgColor
        mainViewContainer.layer.shadowOffset = CGSize(width: 0, height: 6)
        mainViewContainer.layer.shadowRadius = 8
        mainViewContainer.layer.shadowOpacity = 0.30
        mainViewContainer.layer.masksToBounds = false
        mainViewContainer.alpha = 0
    }
    
    private func configureTitleLabel(with text: String) {
        titleLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configureButtonsStackView() {
        buttonsStuckView.axis = .vertical
        buttonsStuckView.spacing = 12
        buttonsStuckView.distribution = .fillEqually
        
        for i in 0..<buttonTitles.count {
            let buttonView = SelectorButtonView()
            buttonView.title = buttonTitles[i]
            if buttonTitles[i] == selectedValue {
                buttonView.isSelected = true
            } else {
                buttonView.isSelected = false
            }
            buttonView.configure()
            buttonView.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.width.greaterThanOrEqualTo(151)
            }
            buttonView.onViewTapCallback = { [weak self] title in
                guard let self = self else { return }
                self.selectedValueCallback?(title, self.selectorType)
                self.onBackgroundTapped()
            }
            buttonsStuckView.addArrangedSubview(buttonView)
        }
        
        
    }
    
    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTapped))
        tapGesture.cancelsTouchesInView = false
        blackoutBackgroundContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onBackgroundTapped() {
        HapticFeedback.selection.vibrate()
        mainViewContainer.popOut(duration: 0.1) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Other methods
    private func makeSelectorState(with title: String) {
        if title == R.string.localizable.settingsGender() {
            selectorType = .userGender
        } else if title == R.string.localizable.onboardingGoalYourGoal() {
            selectorType = .userGoal
        } else {
            selectorType = .units
        }
    }
    
    private func makeButtonTitles() {
        switch selectorType {
        case .userGender:
            buttonTitles = [
                R.string.localizable.onboardingGenderMale(),
                R.string.localizable.onboardingGenderFemale()
            ]
        case .units:
            let impUnits = R.string.localizable.unitsKg() + " / " + R.string.localizable.unitsCm()
            let usUnits = R.string.localizable.unitsLbs() + " / " + R.string.localizable.unitsFt()
            buttonTitles = [impUnits, usUnits]
        case .userGoal:
            buttonTitles = [
                R.string.localizable.onboardingGoalLoseWeight(),
                R.string.localizable.onboardingGoalGainWeight(),
                R.string.localizable.onboardingGoalMaintainWeight()
            ]
        }
    }
}

// MARK: - Setup cpnstraints
extension ChangeSettingsSelectorView {
    
    private func setupConstraints() {
        
        blackoutBackgroundContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(24)
        }
        
        buttonsStuckView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).inset(-12)
        }
        
        mainViewContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(yPos)
        }
    }
}
