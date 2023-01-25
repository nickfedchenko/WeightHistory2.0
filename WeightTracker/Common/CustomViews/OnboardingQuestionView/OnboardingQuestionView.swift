//
//  OnboardingQuestionView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class OnboardingQuestionView: UIView {
    
    // MARK: - Property list
    private var quesetionTitleLabel = UILabel()
    private var buttonsStackView = UIStackView()
    
    var answerButtonPressed: ((_: UIButton, Int) -> Void)?
    
    private let buttonGoalWeightTitles = [
        R.string.localizable.onboardingGoalLoseWeight(),
        R.string.localizable.onboardingGoalGainWeight(),
        R.string.localizable.onboardingGoalMaintainWeight()
    ]
    private let buttonHowOftenTitles = [
        R.string.localizable.onboardingQuestionsEveryday(),
        R.string.localizable.onboardingQuestionsEveryTwoThree(),
        R.string.localizable.onboardingQuestionsEveryWeek(),
        R.string.localizable.onboardingQuestionsOther()
    ]
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func setupGoalButtons() {
        quesetionTitleLabel.text = R.string.localizable.onboardingGoalYourGoal()
        setupStackViewButtons(withButtonTitles: buttonGoalWeightTitles)
    }
    
    func setupHowOftenButtons() {
        quesetionTitleLabel.text = R.string.localizable.onboardingQuestionsHowOften()
        setupStackViewButtons(withButtonTitles: buttonHowOftenTitles)
    }
    
    //MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureQuestionLabel()
        configureButtonsStackView()
    }
    
    private func addSubViews() {
        addSubview(quesetionTitleLabel)
        addSubview(buttonsStackView)
    }
    
    private func configureQuestionLabel() {
        quesetionTitleLabel.textAlignment = .center
        quesetionTitleLabel.numberOfLines = 0
        quesetionTitleLabel.font = R.font.openSansSemiBold(size: 22)
        quesetionTitleLabel.textColor = .onboardingDescriptionColor
    }
    
    private func configureButtonsStackView() {
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 16
    }
    
    // MARK: - Other private methods
    private func setupStackViewButtons(withButtonTitles array: [String]) {
        var buttonsArray: [UIButton] = []
        for i in 0..<array.count {
            let button = ActionButton(type: .custom)
            button.makeWhiteState()
            button.tag = i
            button.setTitle(array[i], for: .normal)
            button.titleLabel?.font = R.font.openSansSemiBold(size: 22)
            button.addTarget(self, action: #selector(answerButtonPressed(button:)), for: .touchUpInside)
            buttonsArray.append(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(72)
            }
        }
        for i in buttonsArray {
            buttonsStackView.addArrangedSubview(i)
        }
    }
    
    //MARK: - Action
    @objc private func answerButtonPressed(button: UIButton) {
        HapticFeedback.selection.vibrate()
        answerButtonPressed?(button, button.tag)
    }
}

// MARK: - Setup cpnstraints
extension OnboardingQuestionView {
    
    private func setupConstraints() {
        
        quesetionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsStackView.snp.top).inset(-24)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
