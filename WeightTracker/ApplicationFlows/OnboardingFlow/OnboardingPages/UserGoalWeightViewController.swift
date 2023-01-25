//
//  UserGoalWeightViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class UserGoalWeightViewController: UIViewController {
    
    // MARK: - Property list
    private var pageControl = CustomPageControl()
    private var goalWeightImageView = UIImageView()
    private var screenDescriptionLabel = UILabel()
    private var userGoalWeightTextField = UITextField()
    private var lineView = UIView()
    private var keyboardButtons = KeyboardButtons()
    private var questionsView = OnboardingQuestionView()
    
    private var viewModel = OnboardingViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupSaveButtonCallback()
        setupQuestionButtonsCallback()
    }
    
    override func viewDidLayoutSubviews() {
        increasePageControlSize()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureHeightImage()
        configureScreenDescriptionLabel()
        configureUserGoalWeightTextField()
        configurePageControl()
        configureLineView()
        configureQuestionsView()
    }
    
    private func addSubViews() {
        view.addSubview(pageControl)
        view.addSubview(goalWeightImageView)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(userGoalWeightTextField)
        view.addSubview(lineView)
        view.addSubview(questionsView)
    }
    
    private func configureView() {
        view.backgroundColor = .mainBackground
        configureBackButtonItem()
    }
    
    // MARK: - BACK BUTTON
    private func configureBackButtonItem() {
        let button = UIButton(type: .custom)
        button.setImage(R.image.backBarItem(), for: .normal)
        button.tintColor = UIColor.onboardingBackItemColor
        button.addTarget(self, action: #selector(routBack), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
    }
    
    // MARK: - HEIGHT IMAGE
    private func configureHeightImage() {
        goalWeightImageView.image = R.image.target()
        goalWeightImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - SCREEN DESCRIPTION
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.textColor = .onboardingDescriptionColor
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.onboardingGoalWeightEnterWeightGoal(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - PAGE CONTROL
    private func configurePageControl() {
        navigationItem.titleView = pageControl
        pageControl.currentPage = 4
    }
    
    private func increasePageControlSize() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
    }
    
    // MARK: - USER GOAL WEIGHT TEXTFIELD
    private func configureUserGoalWeightTextField() {
        userGoalWeightTextField.backgroundColor = .clear
        userGoalWeightTextField.tintColor = .weightPrimary
        userGoalWeightTextField.textColor = .weightPrimary
        userGoalWeightTextField.textAlignment = .center
        userGoalWeightTextField.font = R.font.openSansSemiBold(size: 22)
        userGoalWeightTextField.keyboardType = .decimalPad
        keyboardButtons.configure(for: .weight)
        userGoalWeightTextField.inputAccessoryView = keyboardButtons
        userGoalWeightTextField.addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
        userGoalWeightTextField.attributedText = NSMutableAttributedString(string: "", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.textPrimaryBlueColor,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 22) ?? UIFont.systemFont(ofSize: 22)
        ])
        userGoalWeightTextField.becomeFirstResponder()
    }
    
    @objc private func textfieldValueChanged() {
        keyboardButtons.saveButtonMainState()
    }
    
    private func configureLineView() {
        lineView.backgroundColor = .onboardingPageControlCurrent
    }
    
    private func dataValidation() -> Bool {
        switch userGoalWeightTextField.isWeightValid(with: keyboardButtons.returnSelectedWeightUnit()) {
        case .empty:
            showSimpleAlert(titleText: R.string.localizable.alertMessageEnterContext())
            return false
        case .normal:
            return true
        case .outOfRange:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectWeight())
            return false
        case .incorrectData:
            return false
        }
    }
    
    // MARK: - QUESTION VIEW
    private func configureQuestionsView() {
        questionsView.setupHowOftenButtons()
        questionsView.alpha = 0
        questionsView.isHidden = true
    }
    
    private func hideMainState() {
        UIView.animate(withDuration: 0.4, animations: {
            self.lineView.alpha = 0
            self.userGoalWeightTextField.alpha = 0
            self.screenDescriptionLabel.alpha = 0
        }, completion:  { _ in
            self.lineView.isHidden = true
            self.userGoalWeightTextField.isHidden = true
            self.screenDescriptionLabel.isHidden = true
        })
    }
    
    func showQuestionsView() {
        questionsView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.questionsView.alpha = 1
        }, completion: nil)
    }
    
    // MARK: - ROUTING
    private func routeToNextVc() {
//        let vc = RateAppViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func routBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - ACTIONS
    private func setupSaveButtonCallback() {
        keyboardButtons.saveButtonCallback = { [weak self] in
            guard let self = self else { return }
            if self.dataValidation() {
                self.viewModel.saveUserGoalWeight(
                    value: self.userGoalWeightTextField.text?.replaceDot() ?? "",
                    unit: self.keyboardButtons.returnSelectedWeightUnit()
                )
                self.userGoalWeightTextField.resignFirstResponder()
                self.hideMainState()
                self.showQuestionsView()
            }
        }
    }
    
    private func setupQuestionButtonsCallback() {
        questionsView.answerButtonPressed = { [weak self] butt, tag in
            guard let self = self, let answer = butt.currentTitle else { return }
            self.viewModel.saveUserWeightFrequency(answer: answer)
            self.routeToNextVc()
        }
    }
}

// MARK: - Setup constraints
extension UserGoalWeightViewController {
    
    private func setupConstraints() {
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        goalWeightImageView.snp.makeConstraints { make in
            make.height.equalTo(98)
            make.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(viewModel.topScreenImageViewConstarint)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(178)
            make.centerX.equalToSuperview()
            make.top.equalTo(userGoalWeightTextField.snp.bottom).offset(2)
        }
        
        userGoalWeightTextField.snp.makeConstraints { make in
            make.top.equalTo(goalWeightImageView.snp.bottom).inset(-50.fitH)
            make.centerX.equalToSuperview()
            make.width.equalTo(178)
        }
        
        questionsView.snp.makeConstraints { make in
            make.top.equalTo(goalWeightImageView.snp.bottom).inset(-13)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
}

