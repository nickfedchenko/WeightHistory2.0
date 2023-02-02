//
//  KeyboardButtons.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

final class KeyboardButtons: UIView {
    
    // MARK: - Property list
    private var segmentControl = KeyboardSegmentedControl()
    private var saveButton = ActionButton(type: .system)
    private var userSettingsService = UserSettingsService.shared
    
    var selectedItemTitle = ""
    var saveButtonCallback: (() -> Void)?
    
    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        segmentControlCallback()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(for unit: Units) {
        segmentControl.configure(for: unit)
        checkSelectedItemTitle(for: unit)
    }
    
    func saveButtonMainState() {
        saveButton.makeMainState(isForSmallState: true)
    }
    
    func returnSelectedHeightUnit() -> LengthUnits {
        if selectedItemTitle == R.string.localizable.unitsCm() {
            return .cm
        } else {
            return .ft
        }
    }
    
    func returnSelectedWeightUnit() -> WeightUnits {
        if selectedItemTitle == R.string.localizable.unitsKg() {
            return .kg
        } else {
            return .lbs
        }
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureSaveButton()
    }
    
    private func addSubViews() {
        addSubview(segmentControl)
        addSubview(saveButton)
    }
    
    private func configureView() {
        backgroundColor = .keyboardBackground
        frame.size.height = 96
    }
    
    // MARK: - SELECTED ITEM TITLE
    private func checkSelectedItemTitle(for unit: Units) {
        if unit == .height {
            selectedItemTitle = R.string.localizable.unitsCm()
        } else {
            selectedItemTitle = R.string.localizable.unitsKg()
        }
    }
    
    private func segmentControlCallback() {
        segmentControl.buttonCallback = { [weak self] button in
            guard let self = self else { return }
            self.selectedItemTitle = button.currentTitle ?? ""
        }
    }
    
    // MARK: - SAVE BUTTON
    private func configureSaveButton() {
        saveButton.setTitle(R.string.localizable.buttonsSave().uppercased(), for: .normal)
        saveButton.makeDisableBorderState(isForSmallState: true)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
    }
    
    @objc private func saveButtonPressed() {
        saveButtonCallback?()
        HapticFeedback.medium.vibrate()
        switch selectedItemTitle {
        case R.string.localizable.unitsFt(): userSettingsService.saveUserLengthUnit(lenght: .ft)
        case R.string.localizable.unitsCm(): userSettingsService.saveUserLengthUnit(lenght: .cm)
        case R.string.localizable.unitsLbs(): userSettingsService.saveUserWeighthUnit(weight: .lbs)
        case R.string.localizable.unitsKg(): userSettingsService.saveUserWeighthUnit(weight: .kg)
        default:
            debugPrint("Something went wrong with saving UserSetting")
        }
    }
}

// MARK: - Constraints
extension KeyboardButtons {
    
    private func setupConstraints() {
        
        segmentControl.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(16)
            make.trailing.equalTo(saveButton.snp.leading).inset(-10)
        }
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(111)
        }
    }
}
