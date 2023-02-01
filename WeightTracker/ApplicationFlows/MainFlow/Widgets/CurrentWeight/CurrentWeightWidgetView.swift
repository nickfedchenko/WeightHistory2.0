//
//  CurrentWeightWidgetView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class CurrentWeightWidgetView: UIView {
    
    // MARK: - Property list
    private var leftFootImageView = UIImageView()
    private var rightFootImageView = UIImageView()
    private var widgetTitleLabel = UILabel()
    private var dateLabel = UILabel()
    private var weightLabel = UILabel()
    private var weightBackgroundView = UIView()
    
    var onWidgetPressed: (() -> Void)?
    var viewModel = CurrentWeightWidgetViewModel()
    
    // MARK: - Configuration
    func configure() {
        configureUI()
        configureViewTapGesture()
    }
    
    func updateWidget() {
        configureDateLabel()
        configureWeightLabel()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        configureView()
        configureFootImages()
        configureWidgetTitleLabel()
        configureDateLabel()
        configureWeightLabel()
        configureWeightBackgroundView()
        setupConstraints()
    }
    
    private func addSubViews() {
        addSubview(leftFootImageView)
        addSubview(rightFootImageView)
        addSubview(widgetTitleLabel)
        addSubview(dateLabel)
        addSubview(weightBackgroundView)
        addSubview(weightLabel)
    }
    
    private func configureView() {
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = UIColor.white.cgColor
        configureViewShadow()
    }
    
    private func configureViewShadow() {
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.20
        layer.masksToBounds = false
    }
    
    private func configureWeightBackgroundView() {
        weightBackgroundView.layer.backgroundColor = UIColor.weightWidgetBackgroundView.cgColor
        weightBackgroundView.layer.cornerRadius = 8
        weightBackgroundView.layer.cornerCurve = .continuous
    }
    
    // MARK: - IMAGES
    private func configureFootImages() {
        leftFootImageView.image = R.image.leftFoot()
        leftFootImageView.contentMode = .scaleAspectFit
        rightFootImageView.image = R.image.rightFoot()
        rightFootImageView.contentMode = .scaleAspectFit
    }
    
    // MARK: - LABELS
    private func configureWidgetTitleLabel() {
//        widgetTitleLabel.attributedText = NSMutableAttributedString(
//            string: R.string.localizable.widgetWeight(),
//            attributes: [
//                NSAttributedString.Key.kern: -0.3,
//                NSAttributedString.Key.font: R.font.promptSemiBold(size: 20) ?? UIFont.systemFont(ofSize: 20),
//                NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
//            ]
        widgetTitleLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.widgetWeight(),
            attributes: [
                NSAttributedString.Key.kern: -0.3,
                NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
                NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
            ]
        )
    }
    
    private func configureDateLabel() {
        viewModel.getDateLabel { [weak self] dateString in
            guard let self = self else { return }
            self.dateLabel.attributedText = NSMutableAttributedString(
                string: dateString,
                attributes: [
                    NSAttributedString.Key.kern: -0.3,
                    NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
                    NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
                ]
            )
        }
    }
    
    private func configureWeightLabel() {
        viewModel.getWeightLabel { [weak self] weightString in
            guard let self = self else { return }
            self.weightLabel.attributedText = NSMutableAttributedString(
                string: weightString,
                attributes: [
                    NSAttributedString.Key.kern: -0.3,
                    NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 15),
                    NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
                ]
            )
        }
    }
    
    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onWeightWidgetTapped))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func onWeightWidgetTapped() {
        onWidgetPressed?()
    }
}

// MARK: - Constraints
extension CurrentWeightWidgetView {
    
    private func setupConstraints() {
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(widgetTitleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        widgetTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(leftFootImageView.snp.centerY)
        }
        
        weightBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(38)
            make.leading.equalTo(weightLabel.snp.leading).inset(-13)
            make.trailing.equalTo(weightLabel.snp.trailing).inset(-13)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
        }
        
        weightLabel.snp.makeConstraints { make in
            make.center.equalTo(weightBackgroundView)
        }
        
        leftFootImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50.fitH)
            make.leading.equalToSuperview().inset(7.fitW)
            make.bottom.equalToSuperview().inset(14.fitH)
            make.width.equalTo(36.fitW)
        }
        
        rightFootImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50.fitH)
            make.trailing.equalToSuperview().inset(7.fitW)
            make.bottom.equalToSuperview().inset(14.fitH)
            make.width.equalTo(36.fitW)
        }
    }
}
