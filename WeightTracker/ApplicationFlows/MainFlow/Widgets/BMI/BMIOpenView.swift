//
//  BMIOpenView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class BMIOpenView: UIView {
    
    // MARK: - Property list
    private var blackoutBackgroundContainer = UIView()
    var mainViewContainer = UIView()
    private var bmiArrowImageView = UIImageView()
    private var bmiScaleImageView = UIImageView()
    private var bmiTitleLabel = UILabel()
    private var closeButton = UIButton()
    private var bmiNumberLabel = UILabel()
    private var upToNormalLabel = UILabel()
    private var myNormalLabel = UILabel()
    private var myIdealLabel = UILabel()
    private var upToNormalIndexLabel = UILabel()
    private var myNormalIndexLabel = UILabel()
    private var myIdealIndexLabel = UILabel()
    private var horizontalBmiScaleView = UIImageView()
    private var bmiIndecatorsTableView = UITableView()
    private var bmiEllipse = UIImageView()
    
    private var viewModel = BMIViewModel()
    
    var onRemoveFromSuperView: (() -> Void)?
    var readyHandler: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func setupInitially() {
       viewModel.getUserLastWeight { [weak self] in
           guard let self = self else { return }
           self.configureUI()
           self.configureViewTapGesture()
           self.readyHandler?()
       }
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        configureView()
        setupConstraints()
        configureBmiIndicatorsTableView()
        configureBmiTitleLabel()
        configureBmiNumberLabel()
        configureCloseButton()
        configureScaleImageView()
        configureArrowImageView()
        configureDescriptionLabels()
        configureIndecesLabels()
        configureHorizontalBmiScaleView()
        configureBmiEllipseView()
    }
    
    private func addSubViews() {
        addSubview(blackoutBackgroundContainer)
        addSubview(mainViewContainer)
        mainViewContainer.addSubview(bmiIndecatorsTableView)
        mainViewContainer.addSubview(bmiScaleImageView)
        mainViewContainer.addSubview(bmiArrowImageView)
        mainViewContainer.addSubview(bmiTitleLabel)
        mainViewContainer.addSubview(bmiNumberLabel)
        mainViewContainer.addSubview(closeButton)
        mainViewContainer.addSubview(upToNormalLabel)
        mainViewContainer.addSubview(myNormalLabel)
        mainViewContainer.addSubview(myIdealLabel)
        mainViewContainer.addSubview(upToNormalIndexLabel)
        mainViewContainer.addSubview(myNormalIndexLabel)
        mainViewContainer.addSubview(myIdealIndexLabel)
        mainViewContainer.addSubview(horizontalBmiScaleView)
        mainViewContainer.addSubview(bmiEllipse)
    }
    
    private func configureView() {
        backgroundColor = .clear
        blackoutBackgroundContainer.layer.backgroundColor = UIColor.blackoutBackground.cgColor
        mainViewContainer.layer.backgroundColor = UIColor.white.cgColor
        mainViewContainer.layer.cornerRadius = 16
        mainViewContainer.layer.cornerCurve = .continuous
        mainViewContainer.layer.shadowColor = UIColor.buttonShadowColor.cgColor
        mainViewContainer.layer.shadowOffset = CGSize(width: 0, height: 12)
        mainViewContainer.layer.shadowRadius = 31
        mainViewContainer.layer.shadowOpacity = 0.49
        mainViewContainer.layer.masksToBounds = false
        mainViewContainer.alpha = 0
    }
    
    // MARK: - CONFIGURE TABLE VIEW
    private func configureBmiIndicatorsTableView() {
        registerCells()
        bmiIndecatorsTableView.dataSource = self
        bmiIndecatorsTableView.backgroundColor = .clear
        bmiIndecatorsTableView.showsVerticalScrollIndicator = false
        bmiIndecatorsTableView.separatorStyle = .none
        bmiIndecatorsTableView.isUserInteractionEnabled = false
    }
    
    private func registerCells() {
        bmiIndecatorsTableView.register(BMIValuesTableViewCell.self, forCellReuseIdentifier: BMIValuesTableViewCell.identifier)
    }
    
    // MARK: - IMAGES
    private func configureHorizontalBmiScaleView() {
        horizontalBmiScaleView.image = R.image.horizontalBmiScale()
    }
    
    private func configureBmiEllipseView() {
        bmiEllipse.image = R.image.bmiEllipse()
    }
    
    private func configureScaleImageView() {
        bmiScaleImageView.image = R.image.bmiScale()
        bmiScaleImageView.contentMode = .scaleAspectFit
    }
    
    private func configureArrowImageView() {
        bmiArrowImageView.image = R.image.bmiArrow()
        bmiArrowImageView.contentMode = .scaleAspectFit
    }

    // MARK: - LABELS
    private func configureBmiTitleLabel() {
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
    
    private func configureBmiNumberLabel() {
        let bmiNumber = Double(round(10 * viewModel.bmi) / 10)
        let stringNumber = String(describing: bmiNumber)
        bmiNumberLabel.attributedText = NSMutableAttributedString(string: stringNumber, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.bmiDescriptionLabelColor.cgColor
        ])
    }

    private func configureDescriptionLabels() {
        // Up to my normal weight
        upToNormalLabel.textAlignment = .left
        upToNormalLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.bmiWidgetUpToMyNormalWeight(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
        // My normal weight
        myNormalLabel.textAlignment = .left
        myNormalLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.bmiWidgetMyNormalWeight(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
        // My ideal weight
        myIdealLabel.textAlignment = .left
        myIdealLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.bmiWidgetMyIdealWeight(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
    }
    
    private func configureIndecesLabels() {
        // Up to my normal weight index
        upToNormalIndexLabel.textAlignment = .right
        upToNormalIndexLabel.attributedText = NSMutableAttributedString(string: viewModel.upToMyNormalWeightString, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansBold(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
        // Up to my normal weight index
        myNormalIndexLabel.textAlignment = .right
        myNormalIndexLabel.attributedText = NSMutableAttributedString(string: viewModel.userNormalWeightString, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansBold(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
        // Up to my normal weight index
        myIdealIndexLabel.textAlignment = .right
        myIdealIndexLabel.attributedText = NSMutableAttributedString(string: viewModel.idealUserWeightString, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansBold(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.indicatorNameLabelColor.cgColor
        ])
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .bmiMainColor
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        onRemoveFromSuperView?()
    }
    
    // MARK: - ANIMATION
    func animateBMI() {
        if viewModel.bmi < 14 {
            bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (-140 * CGFloat.pi / 180))
        } else if viewModel.bmi <= 30 {
            firstBmiAnimate()
        } else {
            secondBmiAnimate()
        }
    }
    
    func setBmiArrowStartPosition() {
        bmiArrowImageView.transform = CGAffineTransform(rotationAngle: (-140 * CGFloat.pi / 180))
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
        
        UIView.animate(withDuration: speed, delay: 0.15, options: .curveLinear, animations: {
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
    
    // MARK: - CONFIGURE TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTapped))
        tapGesture.cancelsTouchesInView = false
        blackoutBackgroundContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onBackgroundTapped() {
        onRemoveFromSuperView?()
    }
}

// MARK: - BMI Indicators TableView DataSource
extension BMIOpenView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.bmiIndicators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BMIValuesTableViewCell.identifier, for: indexPath) as? BMIValuesTableViewCell
        if viewModel.bmiType.text == viewModel.bmiIndicators[indexPath.row].text {
            cell?.isCellSelected = true
        }
        cell?.configureCell(
            indicatorColor: viewModel.bmiIndicators[indexPath.row].color,
            indicatorName: viewModel.bmiIndicators[indexPath.row].text,
            indicatorIndex: viewModel.bmiIndicators[indexPath.row].indexText
        )
        return cell ?? UITableViewCell()
    }
}

// MARK: - Setup cpnstraints
extension BMIOpenView {
    
    private func setupConstraints() {
        
        blackoutBackgroundContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainViewContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        
        bmiIndecatorsTableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(horizontalBmiScaleView.snp.bottom).offset(30)
            make.height.equalTo(244)
        }
        
        bmiTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(28)
            make.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(18)
        }
        
        bmiScaleImageView.snp.makeConstraints { make in
            make.width.equalTo(128)
            make.height.equalTo(128)
            make.top.equalToSuperview().inset(36)
            make.centerX.equalToSuperview()
        }
        
        bmiArrowImageView.snp.makeConstraints { make in
            make.center.equalTo(bmiScaleImageView.snp.center)
            make.width.equalTo(17.34)
            make.height.equalTo(128)
        }
        
        bmiNumberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bmiScaleImageView.snp.bottom).inset(8)
        }
        
        upToNormalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(bmiScaleImageView.snp.bottom).offset(1)
        }
        
        upToNormalIndexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(upToNormalLabel.snp.centerY)
        }
        
        myNormalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(upToNormalLabel.snp.bottom).offset(8)
        }
        
        myNormalIndexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(myNormalLabel.snp.centerY)
        }
        
        myIdealLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(myNormalLabel.snp.bottom).offset(8)
        }
        
        myIdealIndexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(myIdealLabel.snp.centerY)
        }
        
        horizontalBmiScaleView.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.top.equalTo(myIdealLabel.snp.bottom).offset(34)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        bmiEllipse.snp.makeConstraints { make in
            var xPos: Double = 0
            let insets: Double = 48
            let frameWidth = frame.size.width
            let horizontalScaleWidth = frameWidth - (insets * 2)
            let onePoint: Double = horizontalScaleWidth / 28
            let halfEllipse = 9.5

            if viewModel.bmi <= 14 {
                make.leading.equalTo(horizontalBmiScaleView.snp.leading)
            } else if viewModel.bmi >= 42 {
                make.trailing.equalTo(horizontalBmiScaleView.snp.trailing)
            } else {
                xPos = (insets / 2) + ((viewModel.bmi - 14) * onePoint) - halfEllipse
                make.leading.equalToSuperview().inset(xPos)
            }
            
            make.centerY.equalTo(horizontalBmiScaleView.snp.centerY)
            make.height.equalTo(19)
            make.width.equalTo(19)
        }
    }
}
