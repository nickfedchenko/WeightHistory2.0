//
//  ChangeSettingsViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit

enum SettingsType {
    case length
    case startWeight
    case goalWeight
    case age
}

final class ChangeSettingsViewController: UIViewController {
    
    // MARK: - Property list
    private var closeButton = UIButton()
    private var titleLabel = UILabel()
    private var changeSettingsTextField = UITextField()
    private var saveButton = ActionButton(type: .system)
    private var mainViewContainer = UIView()
    private var blackoutView = UIView()
    
    private var settingsType: SettingsType = .startWeight
    var closeCallback: (() -> Void)?
    
    var viewModel: SettingsViewModel?
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeCallback?()
        deleteKeyboardObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureMainViewContainer()
    }
    
    // MARK: - Public methods
    func setupTitleLabel(section: Int, row: Int) {
        titleLabel.text = viewModel?.settingsData[section][row].title
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureTitleLabel()
        configureCloseButton()
        configureTextField()
        dissmisVcWhenTapBlackOutView()
        configureSaveButton()
    }
    
    private func addSubViews() {
        view.addSubview(mainViewContainer)
        view.addSubview(blackoutView)
        mainViewContainer.addSubview(closeButton)
        mainViewContainer.addSubview(titleLabel)
        mainViewContainer.addSubview(changeSettingsTextField)
        mainViewContainer.addSubview(saveButton)
    }
    
    private func configureMainViewContainer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.topColorForAddMeasurementGradient.cgColor, UIColor.keyboardBackground.cgColor]
        gradientLayer.locations = [0,1]
        gradientLayer.cornerRadius = 16
        gradientLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        gradientLayer.cornerCurve = .continuous
        gradientLayer.frame = mainViewContainer.bounds
        mainViewContainer.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureTitleLabel() {
        titleLabel.font = FontService.shared.localFont(size: 20, bold: false)
        titleLabel.textColor = .weightPrimary
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .weightPrimary
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        HapticFeedback.selection.vibrate()
        dismiss(animated: true)
    }
    
    // MARK: - TEXT FIELD
    private func configureTextField() {
        changeSettingsTextField.layer.cornerRadius = 16
        changeSettingsTextField.layer.cornerCurve = .continuous
        changeSettingsTextField.backgroundColor = .white
        changeSettingsTextField.layer.borderWidth = 1
        changeSettingsTextField.layer.borderColor = UIColor.textFieldBorderGrayColor.cgColor
        changeSettingsTextField.textColor = .weightPrimary
        changeSettingsTextField.tintColor = .weightPrimary
        changeSettingsTextField.textAlignment = .center
        changeSettingsTextField.keyboardType = .decimalPad
        changeSettingsTextField.becomeFirstResponder()
        changeSettingsTextField.delegate = self
        changeSettingsTextField.font = FontService.shared.localFont(size: 22, bold: false)
        configureTextFieldShadow()
        getMeasurement()
    }
    
    private func getMeasurement() {
        guard let vm = viewModel else { return }
        clearMeasurementResult()
        switch titleLabel.text {
        case R.string.localizable.settingsHeight():
            settingsType = .length
            changeSettingsTextField.text = " " + vm.userLengthUnit
        case R.string.localizable.settingsAge():
            settingsType = .age
            changeSettingsTextField.text = ""
        case R.string.localizable.settingsWeightGoal():
            settingsType = .goalWeight
            changeSettingsTextField.text = " " + vm.userWeightUnit
        case R.string.localizable.settingsStartingWeight():
            settingsType = .startWeight
            changeSettingsTextField.text = " " + vm.userWeightUnit
        default:
            break
        }
    }
    
    private func configureTextFieldShadow() {
        changeSettingsTextField.layer.shadowColor = UIColor.textFieldShadowColor.cgColor
        changeSettingsTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        changeSettingsTextField.layer.shadowRadius = 8
        changeSettingsTextField.layer.shadowOpacity = 0.75
        changeSettingsTextField.layer.masksToBounds = false
    }
    
    // MARK: - SAVE BUTTON
    private func configureSaveButton() {
        saveButton.setTitle(R.string.localizable.buttonsSave(), for: .normal)
        saveButton.makeAddMeasurementState(with: .weight)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
    }
    
    @objc private func saveButtonPressed() {
        HapticFeedback.medium.vibrate()
        guard let vm = viewModel else { return }
        switch vm.isMeasurementResultValid(for: settingsType) {
        case .empty:
            showSimpleAlert(titleText: R.string.localizable.alertMessageEnterContext())
        case .normal:
            switch settingsType {
            case .length:
                vm.saveUserNewHeight()
            case .age:
                vm.saveUserNewAge()
            case .startWeight:
                vm.saveUserNewStartingWeight()
            case .goalWeight:
                vm.saveUserNewGoalWeight()
            }
            dismiss(animated: true)
        case .outOfRange:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectData())
            getMeasurement()
        case .incorrectData:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectData())
            getMeasurement()
        }
    }
    
    // MARK: - KEYBOARD OBSERVERS
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func deleteKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    private func clearMeasurementResult() {
        viewModel?.measurementStringResult = ""
    }
    
    // MARK: - TAP GESTURE
    private func dissmisVcWhenTapBlackOutView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        tapGesture.cancelsTouchesInView = false
        self.blackoutView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - TEXT FIELD DELEGATE
extension ChangeSettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel?.measurementStringResult += string
        if string.count == 0 {
            viewModel?.measurementStringResult.removeLast()
        }
        return true
    }
}

// MARK: - Constraints
extension ChangeSettingsViewController {
    
    private func setupConstraints() {
        
        mainViewContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(254)
        }
        
        blackoutView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(mainViewContainer.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeButton.snp.centerY)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(30)
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
        
        changeSettingsTextField.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).inset(-24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(64)
        }
        
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
            make.top.equalTo(changeSettingsTextField.snp.bottom).inset(-12)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
