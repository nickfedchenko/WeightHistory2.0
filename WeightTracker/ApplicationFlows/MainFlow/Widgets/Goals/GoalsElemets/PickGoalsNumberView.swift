//
//  PickGoalsNumberView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

struct GoalsForPickModel {
    let number: Int
    let name: String
}

final class PickGoalsNumberView: UIView {
    
    // MARK: - Property list
    private var milestonePicker = UIPickerView()
    private var doneButton = UIButton(type: .system)
    private var oneMileLabel = UILabel()
    private var lineForPickerView = UIView()
    
    private var viewModel = GoalsViewModel()
    
    private var milestonesForPickArray: [GoalsForPickModel] = []
    private var milestonesNumber: Int = 10
    var onDoneButtonPressed: (() -> Void)?
    
    // MARK: - Pubic methods
    func configure() {
        viewModel.configure()
        getMilestonesForPickArray()
        getMilestonesNumber()
        configureUI()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureLineForPickerView()
        configureMilestonePicker()
        configureOneMileLabel()
        configureDoneButton()
    }
    
    private func addSubViews() {
        addSubview(lineForPickerView)
        addSubview(milestonePicker)
        addSubview(doneButton)
        addSubview(oneMileLabel)
    }
    
    private func configureView() {
        backgroundColor = .milestoneUnselectedColor
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        layer.shadowColor = UIColor.pickMileShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.49
        layer.masksToBounds = false
    }
    
    private func configureLineForPickerView() {
        lineForPickerView.layer.cornerRadius = 8
        lineForPickerView.layer.cornerCurve = .continuous
        lineForPickerView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    private func configureMilestonePicker() {
        milestonePicker.delegate = self
        milestonePicker.dataSource = self
        milestonePicker.selectRow(viewModel.milestones - 2, inComponent: 0, animated: true)
    }
    
    private func configureOneMileLabel() {
        let text = R.string.localizable.milestoneOneMile() + viewModel.calculateOneMileForPicker(milestoneIndex: milestonesNumber)
        oneMileLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 20) ?? UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    // MARK: - DONE BUTTON
    private func configureDoneButton() {
        doneButton.setTitle(R.string.localizable.buttonsDone(), for: .normal)
        doneButton.backgroundColor = .weightPrimary
        doneButton.titleLabel?.font = R.font.promptSemiBold(size: 20)
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 8
        doneButton.layer.cornerCurve = .continuous
    }
    
    @objc private func doneButtonPressed() {
        viewModel.saveMilestonesNumber(index: milestonesNumber)
        onDoneButtonPressed?()
    }
    
    // MARK: - Other private methods
    private func getMilestonesForPickArray() {
        for i in 2...10 {
            milestonesForPickArray.append(.init(number: i, name: R.string.localizable.milestoneMiniGoalSegments()))
        }
    }
    
    private func getMilestonesNumber() {
        milestonesNumber = viewModel.milestones
    }
}

// MARK: - Picker delegate & data source
extension PickGoalsNumberView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        milestonesForPickArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.subviews[1].alpha = 0
        
        let pickerLabel = UILabel()
        let text = "\(milestonesForPickArray[row].number)" + milestonesForPickArray[row].name
        let attrString = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 23) ?? UIFont.boldSystemFont(ofSize: 23),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
        pickerLabel.textAlignment = .center
        pickerLabel.attributedText = attrString
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        milestonesNumber = milestonesForPickArray[row].number
        configureOneMileLabel()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        34
    }
}

// MARK: - Setup cpnstraints
extension PickGoalsNumberView {
    
    private func setupConstraints() {
        
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(74)
            make.top.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().inset(18)
        }
        
        milestonePicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(53)
            make.height.equalTo(169)
        }
        
        oneMileLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.centerY.equalTo(doneButton.snp.centerY)
        }
        
        lineForPickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(34)
            make.centerY.equalTo(milestonePicker)
        }
    }
}
