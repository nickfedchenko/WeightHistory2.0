//
//  UserHeightViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class UserHeightViewController: UIViewController {
    
    // MARK: - Property list
    private var pageControl = CustomPageControl()
    private var heightImageView = UIImageView()
    private var screenDescriptionLabel = UILabel()
    private var userHeightTextField = UITextField()
    private var lineView = UIView()
    private var keyboardButtons = KeyboardButtons()
    
    private var viewModel = OnboardingViewModel()
            
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupSaveButtonCallback()
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
        configureHeightTextField()
        configurePageControl()
        configureLineView()
    }
    
    private func addSubViews() {
        view.addSubview(pageControl)
        view.addSubview(heightImageView)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(userHeightTextField)
        view.addSubview(lineView)
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
        heightImageView.image = R.image.height()
        heightImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - SCREEN DESCRIPTION
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.textColor = .onboardingDescriptionColor
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.onboardingHeightEnterHeight(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - PAGE CONTROL
    private func configurePageControl() {
        navigationItem.titleView = pageControl
        pageControl.currentPage = 2
    }
    
    private func increasePageControlSize() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
    }
    
    // MARK: - HEIGHT TEXTFIELD
    private func configureHeightTextField() {
        userHeightTextField.backgroundColor = .clear
        userHeightTextField.tintColor = .textPrimaryBlueColor
        userHeightTextField.textColor = .textPrimaryBlueColor
        userHeightTextField.font = R.font.openSansSemiBold(size: 22)
        userHeightTextField.textAlignment = .center
        userHeightTextField.keyboardType = .decimalPad
        keyboardButtons.configure(for: .height)
        userHeightTextField.inputAccessoryView = keyboardButtons
        userHeightTextField.addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
        userHeightTextField.attributedText = NSMutableAttributedString(
            string: "",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.textPrimaryBlueColor,
                NSAttributedString.Key.font: R.font.openSansSemiBold(size: 22) ?? UIFont.systemFont(ofSize: 22)
            ]
        )
        userHeightTextField.becomeFirstResponder()
    }
    
    @objc private func textfieldValueChanged() {
        keyboardButtons.saveButtonMainState()
    }
    
    private func dataValidation() -> Bool {
        switch userHeightTextField.isHeightValid(with: keyboardButtons.returnSelectedHeightUnit()) {
        case .empty:
            showSimpleAlert(titleText: R.string.localizable.alertMessageEnterContext())
            return false
        case .normal:
            return true
        case .outOfRange:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectHeight())
            return false
        case .incorrectData:
            return false
        }
    }
    
    private func configureLineView() {
        lineView.backgroundColor = .onboardingPageControlCurrent
    }
    
    // MARK: - ROUTING
    private func routeToNextVc() {
        let vc = UserWeightViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func routBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Actions
    private func setupSaveButtonCallback() {
        keyboardButtons.saveButtonCallback = { [weak self] in
            guard let self = self else { return }
            if self.dataValidation() {
                self.viewModel.saveUserHeight(
                    value: self.userHeightTextField.text?.replaceDot() ?? "",
                    unit: self.keyboardButtons.returnSelectedHeightUnit()
                )
                self.routeToNextVc()
            }
        }
    }
}

// MARK: - Setup constraints
extension UserHeightViewController {
    
    private func setupConstraints() {
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        heightImageView.snp.makeConstraints { make in
            make.height.equalTo(98)
            make.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(viewModel.topScreenImageViewConstarint)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(178)
            make.centerX.equalToSuperview()
            make.top.equalTo(userHeightTextField.snp.bottom).offset(2)
        }
        
        userHeightTextField.snp.makeConstraints { make in
            make.top.equalTo(heightImageView.snp.bottom).inset(-50.fitH)
            make.centerX.equalToSuperview()
            make.width.equalTo(178)
            
        }
    }
}

