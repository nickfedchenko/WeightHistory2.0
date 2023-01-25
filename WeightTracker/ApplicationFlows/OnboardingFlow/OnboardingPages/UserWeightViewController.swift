//
//  UserWeightViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class UserWeightViewController: UIViewController {
    
    // MARK: - Property list
    private var pageControl = CustomPageControl()
    private var weightImageView = UIImageView()
    private var screenDescriptionLabel = UILabel()
    private var userWeightTextField = UITextField()
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
        configureWeightImage()
        configureScreenDescriptionLabel()
        configureUserWeightTextField()
        configurePageControl()
        configureLineView()
        configureQuestionsView()
        configureUIElementsStartVisability()
    }
    
    private func addSubViews() {
        view.addSubview(pageControl)
        view.addSubview(weightImageView)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(userWeightTextField)
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
    
    // MARK: - WEIGHT IMAGE
    private func configureWeightImage() {
        weightImageView.image = R.image.weight()
        weightImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - SCREEN DESCRIPTION
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.textColor = .onboardingDescriptionColor
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.onboardingWeightEnterWeight(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - PAGE CONTROL
    private func configurePageControl() {
        navigationItem.titleView = pageControl
        pageControl.currentPage = 3
    }
    
    private func increasePageControlSize() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
    }
    
    // MARK: - USER WEIGHT TEXTFIELD
    private func configureUserWeightTextField() {
        userWeightTextField.backgroundColor = .clear
        userWeightTextField.tintColor = .textPrimaryBlueColor
        userWeightTextField.textColor = .textPrimaryBlueColor
        userWeightTextField.font = R.font.openSansSemiBold(size: 22)
        userWeightTextField.textAlignment = .center
        userWeightTextField.keyboardType = .decimalPad
        keyboardButtons.configure(for: .weight)
        userWeightTextField.inputAccessoryView = keyboardButtons
        userWeightTextField.addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
        userWeightTextField.attributedText = NSMutableAttributedString(
            string: "",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.textPrimaryBlueColor,
                NSAttributedString.Key.font: R.font.openSansSemiBold(size: 22) ?? UIFont.systemFont(ofSize: 22)
            ]
        )
    }
    
    private func configureLineView() {
        lineView.backgroundColor = .onboardingPageControlCurrent
    }
    
    @objc private func textfieldValueChanged() {
        keyboardButtons.saveButtonMainState()
    }
    
    private func dataValidation() -> Bool {
        switch userWeightTextField.isWeightValid(with: keyboardButtons.returnSelectedWeightUnit()) {
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
        questionsView.setupGoalButtons()
    }
    
    private func setupQuestionButtonsCallback() {
        questionsView.answerButtonPressed = { [weak self] butt, tag in
            guard let self = self, let answer = butt.currentTitle else { return }
            self.viewModel.saveUserGoal(answer: answer)
            self.hideQuestionView()
            self.showMainView()
        }
    }
    
    // MARK: - VIEW VISABILITY CONFIGURATIONS
    private func configureUIElementsStartVisability() {
        lineView.alpha = 0
        userWeightTextField.alpha = 0
        screenDescriptionLabel.alpha = 0
        lineView.isHidden = true
        userWeightTextField.isHidden = true
        screenDescriptionLabel.isHidden = true
    }
    
    private func showMainView() {
        lineView.isHidden = false
        userWeightTextField.isHidden = false
        screenDescriptionLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.lineView.alpha = 1
            self.userWeightTextField.alpha = 1
            self.screenDescriptionLabel.alpha = 1
        }, completion: { _ in
            self.userWeightTextField.becomeFirstResponder()
        })
    }
    
    private func hideQuestionView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.questionsView.alpha = 0
        }, completion:  { _ in
            self.questionsView.isHidden = true
        })
    }
    
    // MARK: - ROUTING
    private func routeToNextVc() {
        let vc = UserGoalWeightViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func routBack() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - ACTION
    private func setupSaveButtonCallback() {
        keyboardButtons.saveButtonCallback = { [weak self] in
            guard let self = self else { return }
            if self.dataValidation() {
                self.viewModel.saveUserStartWeight(
                    value: self.userWeightTextField.text?.replaceDot() ?? "",
                    unit: self.keyboardButtons.returnSelectedWeightUnit()
                )
                self.routeToNextVc()
            }
        }
    } 
}

// MARK: - Setup constraints
extension UserWeightViewController {
    
    private func setupConstraints() {
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            
        }
        
        weightImageView.snp.makeConstraints { make in
            make.height.equalTo(98)
            make.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(viewModel.topScreenImageViewConstarint)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(178)
            make.centerX.equalToSuperview()
            make.top.equalTo(userWeightTextField.snp.bottom).offset(2)
        }
        
        userWeightTextField.snp.makeConstraints { make in
            make.top.equalTo(weightImageView.snp.bottom).inset(-50.fitH)
            make.centerX.equalToSuperview()
            make.width.equalTo(178)
        }
        
        questionsView.snp.makeConstraints { make in
            make.top.equalTo(weightImageView.snp.bottom).inset(-13)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}

