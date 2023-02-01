//
//  SettingsTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit

enum SettingsCellType {
    case withSwith
    case withSelector
    case withTextField
    case withTouchEvent
}

final class SettingsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: SettingsTableViewCell.self)
    
    // MARK: - Property list
    private var titleLabel = UILabel()
    private var valueLabel = UILabel()
    private var chevronImageView = UIImageView()
    private var switchSelector = UISwitch()
    private var viewContainer = ShadowCellView()
    
    var cellType: SettingsCellType = .withSelector
    
    var cellWithSelectorCallback: ((CGFloat, String, String) -> Void)?
    var cellWithTextfieldCallback: (() -> Void)?
    var hapticFeedbackCallback: ((Bool) -> Void)?
    var appleHealthCallback: ((Bool) -> Void)?
    var reccomendToFriendsCallback: (() -> Void)?
    var rateAppCallback: (() -> Void)?
    var contactUsCallback: (() -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSwtichState(isEnabled: Bool) {
        switchSelector.isEnabled = isEnabled
    }
    
    // MARK: - Public methods
    func configure(titleForCell titleText: String, value: String, cellType type: SettingsCellType, isAppleHealthOn: Bool, isHapticFeedbackOn: Bool) {
        cellType = type
        configureTitleLabel(with: titleText)
        
        switch type {
        case .withSwith:
            showSwitchState()
            if titleText == R.string.localizable.settingsHealthSync() {
                configureSwitchSelector(with: isAppleHealthOn)
            } else {
                configureSwitchSelector(with: isHapticFeedbackOn)
            }
        case .withSelector:
            showSelectorState()
            configureValueLabel(with: value)
        case .withTextField:
            showTextFieldState()
            configureValueLabel(with: value)
        case .withTouchEvent:
            showTouchEventState()
        }
        configureViewContainerTapGesture()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureChevronImageView()
    }
    
    private func addSubViews() {
        contentView.addSubview(viewContainer)
        viewContainer.addSubview(titleLabel)
        viewContainer.addSubview(chevronImageView)
        viewContainer.addSubview(switchSelector)
        viewContainer.addSubview(valueLabel)
    }
    
    private func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.clipsToBounds = false
        clipsToBounds = false
    }
    
    private func showSwitchState() {
        switchSelector.isHidden = false
        chevronImageView.isHidden = true
        valueLabel.isHidden = true
    }
    
    private func showSelectorState() {
        switchSelector.isHidden = true
        chevronImageView.isHidden = false
        valueLabel.isHidden = false
    }
    
    private func showTextFieldState() {
        switchSelector.isHidden = true
        chevronImageView.isHidden = false
        valueLabel.isHidden = false
    }
    
    private func showTouchEventState() {
        switchSelector.isHidden = true
        chevronImageView.isHidden = false
        valueLabel.isHidden = true
    }
    
    private func configureTitleLabel(with text: String) {
        titleLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 16) ?? UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.settingsTitleColor
        ])
    }
    
    private func configureChevronImageView() {
        chevronImageView.image = R.image.chevronRight()
    }
    
    private func configureSwitchSelector(with value: Bool) {
        switchSelector.isOn = value
        switchSelector.onTintColor = .weightPrimary
        switchSelector.tintColor = .milestoneUnselectedColor
        switchSelector.backgroundColor = .milestoneUnselectedColor
        switchSelector.layer.cornerRadius = 16
        switchSelector.addTarget(self, action: #selector(splitSwitchValueChanged), for: .valueChanged)

    }
    
    private func configureValueLabel(with text: String) {
        valueLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 16) ?? UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
        valueLabel.textAlignment = .right
    }
    
    private func configureViewContainerTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCellTapped))
        tapGesture.cancelsTouchesInView = false
        if cellType != .withSwith {
            viewContainer.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - Actions
    @objc private func onCellTapped() {
        switch cellType {
        case .withSwith:
            return
        case .withSelector:
            guard let globalPoint = self.superview?.convert(frame, to: nil),
                  let text = titleLabel.text,
                  let selectedValue = valueLabel.text else { return }
            cellWithSelectorCallback?(globalPoint.origin.y, text, selectedValue)
        case .withTextField:
            cellWithTextfieldCallback?()
        case .withTouchEvent:
            if titleLabel.text == R.string.localizable.settingsReccomended() {
                reccomendToFriendsCallback?()
            } else if titleLabel.text == R.string.localizable.settingsDoYouLikeApp() {
                rateAppCallback?()
            } else {
                contactUsCallback?()
            }
        }
    }
    
    @objc private func splitSwitchValueChanged(sender: UISwitch) {
        if titleLabel.text == R.string.localizable.settingsHealthSync() {
            appleHealthCallback?(sender.isOn)
        } else {
            hapticFeedbackCallback?(sender.isOn)
        }
    }
}

// MARK: - Constraints
extension SettingsTableViewCell {
    
    private func setupConstraints() {
        
        viewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(chevronImageView.snp.leading).inset(-20)
        }
        
        switchSelector.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.equalTo(9)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(15)
        }
    }
}
