//
//  BMIWidgetView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class BMIWidgetView: UIView {
    
    //MARK: - Property list
    private var bmiArrowImageView = UIImageView()
    private var bmiScaleImageView = UIImageView()
    private var bmiTitleLabel = UILabel()
    private var bmiDiscriptionLabel = UILabel()
    private var bmiNumberLabel = UILabel()
    private var bodyImageView = UIImageView()
    
    private var viewModel = BMIViewModel()
    var onWidgetPressed: (() -> Void)?
    
    // MARK: - Public methods
    func configure() {
        viewModel.getUserLastWeight { [weak self] in
            self?.configureUI()
            self?.animateBMI()
            self?.configureViewTapGesture()
        }
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureWidgetTitle()
        configureBmiDescriptionLabel()
        configureBmiNumberLabel()
        configureScaleImageView()
        configureArrowImageView()
        configureBodyImageView()
        configureView()
    }
    
    private func addSubViews() {
        addSubview(bodyImageView)
        addSubview(bmiScaleImageView)
        addSubview(bmiArrowImageView)
        addSubview(bmiTitleLabel)
        addSubview(bmiDiscriptionLabel)
        addSubview(bmiNumberLabel)
    }
    
    private func configureView() {
        backgroundColor = .clear
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.20
        layer.masksToBounds = false
    }
    
    // MARK: - TITLE LABEL
    private func configureWidgetTitle() {
//        bmiTitleLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.widgetBmi().uppercased(), attributes: [
//            NSAttributedString.Key.kern: -0.3,
//            NSAttributedString.Key.font: R.font.promptSemiBold(size: 20) ?? UIFont.systemFont(ofSize: 20),
//            NSAttributedString.Key.foregroundColor: UIColor.bmiMainColor.cgColor
//        ])
        bmiTitleLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.widgetBmi().uppercased(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
            NSAttributedString.Key.foregroundColor: UIColor.bmiMainColor.cgColor
        ])
    }
    
    // MARK: - DESCRIPTION LABEL
    private func configureBmiDescriptionLabel() {
        bmiDiscriptionLabel.attributedText = NSMutableAttributedString(string: viewModel.bmiType.text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.bmiDescriptionLabelColor.cgColor
        ])
        bmiDiscriptionLabel.adjustsFontSizeToFitWidth = true
        bmiDiscriptionLabel.minimumScaleFactor = 0.5
    }
    
    // MARK: - NUMBER BMI LABEL
    private func configureBmiNumberLabel() {
        let bmiNumber = Double(round(10 * viewModel.bmi) / 10)
        let stringNumber = String(describing: bmiNumber)
        bmiNumberLabel.attributedText = NSMutableAttributedString(string: stringNumber, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.bmiDescriptionLabelColor.cgColor
        ])
    }
    
    // MARK: - IMAGES CONFIGURATION
    private func configureScaleImageView() {
        bmiScaleImageView.image = R.image.bmiScale()
    }
    
    private func configureArrowImageView() {
        bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (-140 * CGFloat.pi / 180))
        bmiArrowImageView.image = R.image.bmiArrow()
        bmiArrowImageView.contentMode = .scaleAspectFit
    }
    
    private func configureBodyImageView() {
        bodyImageView.image = R.image.bmiBackground()
        bodyImageView.contentMode = .scaleAspectFit

    }
    
    // MARK: - Animation
    private func animateBMI() {
        if viewModel.bmi < 14 {
            bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (-140 * CGFloat.pi / 180))
        } else if viewModel.bmi <= 30 {
            firstBmiAnimate()
        } else {
            secondBmiAnimate()
        }
    }
    
    private func firstBmiAnimate() {
        let zeroPosition: CGFloat = 28
        let bmi: CGFloat = CGFloat(viewModel.bmi)
        let startPosition: CGFloat = 140
        let bounce: CGFloat = 15
        let degrees = (zeroPosition - bmi) * CGFloat(-10)
        let speedCoeff = 0.018
        let speed = (startPosition + degrees + bounce) * speedCoeff
        
        UIView.animate(withDuration: speed, delay: 0.3,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 6,
                       options: .curveEaseOut) {
        self.bmiArrowImageView.transform = CGAffineTransform (rotationAngle: ((degrees) * CGFloat.pi /
        180) )
        }
        
    }
    
    private func secondBmiAnimate() {
        let zeroPosition: CGFloat = 28
        let bmi: CGFloat = CGFloat(viewModel.bmi)
        let startPosition: CGFloat = 140
        var bounce: CGFloat = 25
        let speedCoeff = 0.003
        var degrees = (zeroPosition - bmi) * CGFloat(-10)
        let speed = startPosition * speedCoeff
        let secondSpeed = (degrees + bounce) * speedCoeff
        
        if bmi > 42 {
            degrees = 140
            bounce = 0
        }
        
        UIView.animate(withDuration: speed, delay: 0.3, options: .curveLinear, animations: {
            self.bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (0 * CGFloat.pi / 180))
        }, completion: { _ in
            UIView.animate(withDuration: secondSpeed, delay: 0, options: .curveLinear, animations: {
                self.bmiArrowImageView.transform = CGAffineTransform(rotationAngle: ((degrees + bounce) * CGFloat.pi / 180))
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (degrees * CGFloat.pi / 180))
                }, completion: nil)

            })
        })
    }
    
    // MARK: - VIEW TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBmiWidgetTapped))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func onBmiWidgetTapped() {
        onWidgetPressed?()
    }
}

// MARK: - Setup cpnstraints
extension BMIWidgetView {
    
    private func setupConstraints() {
        
        bmiTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(12)
        }
        
        bmiDiscriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        bmiScaleImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(95)
            make.width.equalTo(95)
        }
        
        bmiArrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(95)
            make.width.equalTo(13)
        }
        
        bmiNumberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalTo(bmiScaleImageView.snp.bottom).offset(1)
        }
        
        bodyImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
