//
//  PaywallCollectionViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import UIKit

final class PaymentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: PaymentCollectionViewCell.self)
    
    // MARK: - Property list
    private var mainLabel = UILabel()
    private var secondLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.weightPrimary.cgColor
            } else {
                layer.borderColor = UIColor.borderGray.cgColor
            }
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(mainTitle: String, secondTitle: String) {
        mainLabel.text = mainTitle
        secondLabel.text = secondTitle
    }
    
    func configure(with model: PayCellModel) {
        mainLabel.text = model.periodTitle + " - " + model.priceString
        secondLabel.text = model.weeklyPriceString + " - " + R.string.localizable.periodsWeek()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureMainLabel()
        configureSecondLabel()
    }
    
    private func addSubViews() {
        contentView.addSubview(mainLabel)
        contentView.addSubview(secondLabel)
    }
    
    private func configureView() {
        contentView.isUserInteractionEnabled = true
        backgroundColor = .clear
        layer.borderColor = UIColor.borderGray.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
    }
    
    private func configureMainLabel() {
        mainLabel.font = R.font.openSansBold(size: 16)
        mainLabel.textColor = .boldBlack
        mainLabel.textAlignment = .left
    }
    
    private func configureSecondLabel() {
        secondLabel.font = R.font.openSansRegular(size: 13)
        secondLabel.textColor = .secondaryGrayText
        secondLabel.textAlignment = .left
    }
}

// MARK: - Setup constraints
extension PaymentCollectionViewCell {
    
    private func setupConstraints() {
        
        mainLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(15)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(15)
        }
    }
}
