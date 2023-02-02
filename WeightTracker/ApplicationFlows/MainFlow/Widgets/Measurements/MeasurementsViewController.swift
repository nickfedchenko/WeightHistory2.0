//
//  MeasurementsViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class MeasurementsViewController: UIViewController {
    
    // MARK: - Property list
//    private var calendarButton = UIButton()         // TODO: - Реализовать после релиза в следующих версиях
    private var closeButton = UIButton()
    private var measurementTodayLabel = UILabel()
    private var measurementTextField = UITextField()
    private var saveButton = ActionButton(type: .system)
    private var mainViewContainer = UIView()
    private var blackoutView = UIView()
    
    var viewType: MeasurementTypes = .weight
    var closeCallback: (() -> Void)?
    
    private var viewModel: MeasurementsViewModel
    
    // MARK: - Init
    init(type: MeasurementTypes) {
        self.viewType = type
        self.viewModel = MeasurementsViewModel(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureMeasurementTodayLabel()
        configureCloseButton()
//        configureCalendarButton()
        configureTextField()
        dissmisVcWhenTapBlackOutView()
        configureSaveButton()
    }
    
    private func addSubViews() {
        view.addSubview(mainViewContainer)
        view.addSubview(blackoutView)
//        mainViewContainer.addSubview(calendarButton)
        mainViewContainer.addSubview(closeButton)
        mainViewContainer.addSubview(measurementTodayLabel)
        mainViewContainer.addSubview(measurementTextField)
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
    
    // MARK: - LABELS
    private func configureMeasurementTodayLabel() {
        configureMeasurementTodayLabelText()
        measurementTodayLabel.font = FontService.shared.localFont(size: 20, bold: false)
        measurementTodayLabel.textColor = viewType.color
    }
    
    private func configureMeasurementTodayLabelText() {
        switch viewType {
        case .chest:    measurementTodayLabel.text = R.string.localizable.measurementHistoryMyChestToday()
        case .waist:    measurementTodayLabel.text = R.string.localizable.measurementHistoryMyWaistToday()
        case .hip:      measurementTodayLabel.text = R.string.localizable.measurementHistoryMyHipToday()
        case .weight:   measurementTodayLabel.text = R.string.localizable.measurementHistoryMyWeightToday()
        case .bmi:      return
        }
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = viewType.color
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        HapticFeedback.selection.vibrate()
        dismiss(animated: true)
    }
    
    // MARK: - SAVE BUTTON
    private func configureSaveButton() {
        saveButton.setTitle(R.string.localizable.buttonsSave(), for: .normal)
        saveButton.makeAddMeasurementState(with: viewType)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
    }
    
    @objc private func saveButtonPressed() {
        HapticFeedback.success.vibrate()
        switch viewModel.isMeasurementResultValid(for: viewType) {
        case .empty:
            showSimpleAlert(titleText: R.string.localizable.alertMessageEnterContext())
        case .normal:
            viewModel.addMeasurement(for: viewType)
            viewModel.amplitudeLogEvent()
            dismiss(animated: true)
        case .outOfRange:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectData())
            getMeasurement()
        case .incorrectData:
            showSimpleAlert(titleText: R.string.localizable.alertMessageIncorrectData())
            getMeasurement()
        }
    }
    
    // MARK: - CALENDAR BUTTON
    //    private func configureCalendarButton() {
    //        calendarButton.addTarget(self, action: #selector(calendarButtonPressed), for: .touchUpInside)
    //        calendarButton.tintColor = widgetType.color
    //        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
    //        calendarButton.setImage(.init(systemName: "calendar", withConfiguration: config), for: .normal)
    //    }
    
    //    @objc private func calendarButtonPressed() {
    //        weak var pvc = presentingViewController
    //        dismiss(animated: true) {
    //            let vc = BodyHistoryWidgetViewController()
    //            vc.widgetType = self.widgetType
    //            pvc?.present(vc, animated: true)
    //        }
    //    }
    
    // MARK: - TEXT FIELD
    private func configureTextField() {
        measurementTextField.layer.cornerRadius = 16
        measurementTextField.layer.cornerCurve = .continuous
        measurementTextField.backgroundColor = .white
        measurementTextField.layer.borderWidth = 1
        measurementTextField.layer.borderColor = UIColor.textFieldBorderGrayColor.cgColor
        measurementTextField.textColor = viewType.color
        measurementTextField.tintColor = viewType.color
        measurementTextField.textAlignment = .center
        measurementTextField.keyboardType = .decimalPad
        measurementTextField.becomeFirstResponder()
        measurementTextField.delegate = self
        measurementTextField.font = FontService.shared.localFont(size: 22, bold: false)
        configureTextFieldShadow()
        getMeasurement()
    }
    
    private func configureTextFieldShadow() {
        measurementTextField.layer.shadowColor = UIColor.textFieldShadowColor.cgColor
        measurementTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        measurementTextField.layer.shadowRadius = 8
        measurementTextField.layer.shadowOpacity = 0.75
        measurementTextField.layer.masksToBounds = false
    }
    
    private func getMeasurement() {
        clearMeasurementResult()
        if viewType == .weight {
            measurementTextField.text = viewModel.getUserWidthUnit()
        } else {
            measurementTextField.text = viewModel.getUserLenghtUnit()
        }
    }
    
    private func clearMeasurementResult() {
        viewModel.measurementStringResult = ""
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
    
    // MARK: - TAP GESTURE
    private func dissmisVcWhenTapBlackOutView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        tapGesture.cancelsTouchesInView = false
        self.blackoutView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - TEXT FIELD DELEGATE
extension MeasurementsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.measurementStringResult += string
        if string.count == 0 {
            viewModel.measurementStringResult.removeLast()
        }
        return true
    }
}

// MARK: - Constraints
extension MeasurementsViewController {
    
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
        
        measurementTodayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeButton.snp.centerY)
        }
        
//        calendarButton.snp.makeConstraints { make in
//            make.centerY.equalTo(closeButton.snp.centerY)
//            make.leading.equalToSuperview().inset(29)
//            make.height.equalTo(28)
//            make.width.equalTo(28)
//        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(30)
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
        
        measurementTextField.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).inset(-24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(64)
        }
        
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
            make.top.equalTo(measurementTextField.snp.bottom).inset(-12)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
