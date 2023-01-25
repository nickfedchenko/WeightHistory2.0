//
//  UserBirthdayViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class UserBirthdayViewController: UIViewController {
    
    // MARK: - Property list
    private var pageControl = CustomPageControl()
    private var birthdayImageView = UIImageView()
    private var screenDescriptionLabel = UILabel()
    private var birthdayDatePicker = UIDatePicker()
    private var saveButton = ActionButton(type: .system)
    private var dateLine = UIView()

    private var viewModel = OnboardingViewModel()
        
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        increasePageControlSize()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureBirthdayImage()
        configureScreenDescriptionLabel()
        configureSaveButton()
        configurePageControl()
        configureDatePicker()
        configureDateLine()
    }
    
    private func addSubViews() {
        view.addSubview(pageControl)
        view.addSubview(birthdayImageView)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(saveButton)
        view.addSubview(dateLine)
        view.addSubview(birthdayDatePicker)
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundMainColor
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
    
    // MARK: - DATE LINE
    private func configureDateLine() {
        dateLine.backgroundColor = .white
        dateLine.layer.cornerRadius = 8
        dateLine.layer.cornerCurve = .continuous
    }
    
    // MARK: - BIRTHDAY IMAGE
    private func configureBirthdayImage() {
        birthdayImageView.image = R.image.birthday()
        birthdayImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - SCREEN DESCRIPTION
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.numberOfLines = 0
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.textColor = .onboardingDescriptionColor
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.onboardingBirthdayEnterBirthday(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - SAVE BUTTON
    private func configureSaveButton() {
        saveButton.setTitle(R.string.localizable.buttonsSave().uppercased(), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.makeDisableState()
    }
    
    @objc private func saveButtonPressed() {
        HapticFeedback.medium.vibrate()
        viewModel.saveUserBirthday(date: birthdayDatePicker.date)
        routeToNextVc()
    }
    
    // MARK: - PAGE CONTROL
    private func configurePageControl() {
        navigationItem.titleView = pageControl
        pageControl.currentPage = 1
    }
    
    private func increasePageControlSize() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
    }
    
    // MARK: - BIRTHDAY DATE PICKER
    private func configureDatePicker() {
        birthdayDatePicker.preferredDatePickerStyle = .wheels
        birthdayDatePicker.datePickerMode = .date
        birthdayDatePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -110, to: Date())
        birthdayDatePicker.maximumDate = Date()
        birthdayDatePicker.setValue(UIColor.clear, forKey: "magnifierLineColor")
        birthdayDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged() {
        saveButton.makeMainState()
    }
    
    // MARK: - ROUTING
    func routeToNextVc() {
        let vc = UserHeightViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func routBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension UserBirthdayViewController {
    
    private func setupConstraints() {
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(90)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
        }
        
        birthdayDatePicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(saveButton.snp.top).offset(viewModel.bottomDatePickerConstraint)
        }
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(birthdayDatePicker.snp.top)
            make.top.equalTo(birthdayImageView.snp.bottom)

        }
        
        birthdayImageView.snp.makeConstraints { make in
            make.height.equalTo(88)
            make.width.equalTo(94)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(viewModel.topScreenImageViewConstarint)
        }
        
        dateLine.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.centerY.equalTo(birthdayDatePicker.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
}
