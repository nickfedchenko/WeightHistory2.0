//
//  BenefitsTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import UIKit

final class BenefitsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: BenefitsTableViewCell.self)
    
    // MARK: - Property list
    private var okImageView = UIImageView()
    private var titleLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(withTitle title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureOkImageView()
        configureTitleLabel()
        configureView()
    }
    
    private func addSubViews() {
        contentView.addSubview(okImageView)
        contentView.addSubview(titleLabel)
    }
    
    private func configureView() {
        backgroundColor = .clear
    }
    
    private func configureOkImageView() {
        okImageView.image = R.image.tickCircle()
    }
    
    private func configureTitleLabel() {
        titleLabel.font = R.font.openSansMedium(size: 14)
        titleLabel.textColor = UIColor.onboardingDescriptionColor
        titleLabel.textAlignment = .left
    }
}

// MARK: - Constraints
extension BenefitsTableViewCell {
    
    private func setupConstraints() {
        
        okImageView.snp.makeConstraints { make in
            make.height.width.equalTo(13)
            make.leading.equalToSuperview().inset(17)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(okImageView.snp.trailing).inset(-13)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(13)
            make.bottom.equalToSuperview()
        }
    }
}
