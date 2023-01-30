//
//  BMIValuesTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class BMIValuesTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: BMIValuesTableViewCell.self)
    
    // MARK: - Property list
    private var indicatorColorView = UIView()
    private var indicatorNameLabel = UILabel()
    private var indicatorIndexLabel = UILabel()
    
    var isCellSelected = false
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configureCell(indicatorColor: UIColor, indicatorName: String, indicatorIndex: String) {
        setupIndicatorColorView(with: indicatorColor)
        setupIndicatorNameLabel(with: indicatorName)
        setupIndicatorIndexLabel(with: indicatorIndex)
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureIndicatorColorView()
        configureIndicatorIndexLabel()
    }
    
    private func addSubViews() {
        contentView.addSubview(indicatorColorView)
        contentView.addSubview(indicatorNameLabel)
        contentView.addSubview(indicatorIndexLabel)
    }
    
    private func configureView() {
        if isCellSelected {
            configureSelectedBackgroundView()
        } else {
            backgroundColor = .clear
        }
    }
    
    private func configureIndicatorColorView() {
        indicatorColorView.layer.cornerRadius = 6
        indicatorColorView.layer.cornerCurve = .continuous
        indicatorColorView.backgroundColor = .clear
    }
    
    private func configureIndicatorIndexLabel() {
        indicatorIndexLabel.font = R.font.openSansBold(size: 15)
        indicatorIndexLabel.textAlignment = .right
        indicatorIndexLabel.textColor = .indicatorNameLabelColor
    }
    
    private func configureSelectedBackgroundView() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        backgroundColor = UIColor.mainBackground
    }
    
    
    // MARK: - SETUP METHODS
    private func setupIndicatorColorView(with color: UIColor) {
        indicatorColorView.layer.backgroundColor = color.cgColor
    }
    
    private func setupIndicatorNameLabel(with text: String) {
        indicatorNameLabel.textAlignment = .left
        indicatorNameLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
    }
    
    private func setupIndicatorIndexLabel(with text: String) {
        indicatorIndexLabel.text = text
    }
}

// MARK: - Constraints
extension BMIValuesTableViewCell {
    
    private func setupConstraints() {
        
        indicatorNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(indicatorColorView.snp.trailing).offset(11)
            make.height.equalTo(18)
            make.centerY.equalTo(indicatorColorView.snp.centerY)
        }
        
        indicatorColorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(7)
            make.height.equalTo(12)
            make.width.equalTo(12)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        indicatorIndexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.height.equalTo(18)
            make.centerY.equalTo(indicatorColorView.snp.centerY)
        }
    }
}
