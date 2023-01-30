//
//  GoalsCircleProgressView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

enum GoalsCircleProgressViewType {
    case open
    case smallSplit
    case smallMaintain
}

final class GoalsCircleProgressView: UIView {
    
    // MARK: - Property list
    private var percentIndexLabel = UILabel()
    private var percentLabel = UILabel()
    private var completeLabel = UILabel()
    private var toGoLabel = UILabel()
    private var percentViewContainer = UIView()
    private var weightDiffLabel = UILabel()
    
    var viewType: GoalsCircleProgressViewType = .open
    var progress = 0.91
    var isGoalSplit = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Indents
    private var toGoTopIndent: CGFloat = 0
    private var percentConteinerTopIndent: CGFloat = 0
    private var completeBottomIndent: CGFloat = 0
    
    // MARK: - Overrides
    override func draw(_ rect: CGRect) {
        drawBackgroundCircle(rect: rect)
        drawProgressCircle(rect: rect)
    }
    
    // MARK: - Public methods
    func configure(percent: Double, weight: Double, weightUnit: String) {
        calculateIndents()
        configureUI()
        configurePercentIndexLabel(percent: percent)
        configureToGoLabel(weight: weight, weightUnit: weightUnit)
    }
    
    func configureMainTainState(weightDiffIndex: Double, weightUnit: String) {
        calculateIndents()
        configureWeightDiffLabel(weightDiffIndex: weightDiffIndex, weightUnits: weightUnit)
        addSubview(weightDiffLabel)
        setupMaintainConstraints()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubviews()
        setupConstraints()
        configureCompleteLabel()
        configurePercentLabel()
    }
    
    private func addSubviews() {
        addSubview(completeLabel)
        addSubview(toGoLabel)
        addSubview(percentViewContainer)
        percentViewContainer.addSubview(percentIndexLabel)
        percentViewContainer.addSubview(percentLabel)
    }
    
    private func configurePercentIndexLabel(percent: Double) {
        var text = ""
        (viewType == .smallSplit && isGoalSplit) ? (text = String(format: "%.0f", percent)) : (text = "\(percent)")

        percentIndexLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configurePercentLabel() {
        percentLabel.text = "%"
        percentLabel.textColor = .weightPrimary
        percentLabel.font = R.font.openSansMedium(size: 16)
    }
    
    private func configureToGoLabel(weight: Double, weightUnit: String) {
        let text = "\(weight) " + weightUnit + " " + R.string.localizable.milestoneToGo()
        let paragraphStyle = NSMutableParagraphStyle()
        
        if UIScreen.main.bounds.width <= 375 && viewType == .smallSplit {
            paragraphStyle.lineHeightMultiple = 0.75
        } else {
            paragraphStyle.lineHeightMultiple = 0.88
        }
        
        toGoLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 12 : 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
        
        toGoLabel.numberOfLines = 0
        toGoLabel.textAlignment = .center
    }
    
    private func configureCompleteLabel() {
        var fontSize: CGFloat = 0
        (viewType == .smallSplit && isGoalSplit) ? (fontSize = 12) : (fontSize = 15)
        completeLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneComplete(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configureWeightDiffLabel(weightDiffIndex: Double, weightUnits: String) {
        var text = ""
        if weightDiffIndex > 0 {
            text = "+\(roundTen(weightDiffIndex)) " + weightUnits
        } else {
            text = "\(roundTen(weightDiffIndex)) " + weightUnits
        }
        weightDiffLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    
    // MARK: - Draw progress view
    private func drawProgressCircle(rect: CGRect) {
        let circleProgress = 1 - progress
        let width: Double = 7.9
        let circleRadius = rect.width / 2
        
        let endPosition = CGFloat(((225 + 45) * circleProgress) - 45) * (-1)
        
        let path = UIBezierPath(
            arcCenter: CGPoint(x: circleRadius, y: circleRadius),
            radius: circleRadius - (width / 2) + 0.2,
            startAngle: 45 * .pi / 180,
            endAngle: endPosition * .pi / 180,
            clockwise: false)
        
        
        let backgroundCirlceLayer = CAShapeLayer()
        backgroundCirlceLayer.path = path.cgPath
        backgroundCirlceLayer.strokeColor = UIColor.milestoneUnselectedColor.cgColor
        backgroundCirlceLayer.fillColor = UIColor.clear.cgColor
        backgroundCirlceLayer.lineWidth = width
        backgroundCirlceLayer.lineCap = CAShapeLayerLineCap.round

        layer.addSublayer(backgroundCirlceLayer)
    
    }
    
    private func drawBackgroundCircle(rect: CGRect) {
        
        let width: Double = 7.5
        let circleRadius = rect.width / 2
        
        let path = UIBezierPath(
            arcCenter: CGPoint(x: circleRadius, y: circleRadius),
            radius: circleRadius - (width / 2),
            startAngle: 135 * .pi / 180,
            endAngle:  45 * .pi / 180,
            clockwise: true)
        
        
        let backgroundCirlceLayer = CAShapeLayer()
        backgroundCirlceLayer.path = path.cgPath
        
        if viewType == .smallMaintain && (progress > 0.5) {
            backgroundCirlceLayer.strokeColor = UIColor.redCircleProgressLineColor.cgColor
        } else if viewType == .smallMaintain && (progress <= 0.5) {
            backgroundCirlceLayer.strokeColor = UIColor.greenCircleProgressLineColor.cgColor
        } else {
            backgroundCirlceLayer.strokeColor = UIColor.weightPrimary.cgColor
        }
        
        backgroundCirlceLayer.fillColor = UIColor.clear.cgColor
        backgroundCirlceLayer.lineWidth = width
        backgroundCirlceLayer.lineCap = CAShapeLayerLineCap.round

        layer.addSublayer(backgroundCirlceLayer)
    }
}

// MARK: - Constraints
extension GoalsCircleProgressView {
    
    private func setupConstraints() {
        
        percentViewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(percentConteinerTopIndent)
            make.centerX.equalToSuperview().inset(1)
            make.height.equalTo(30)
        }
        
        percentIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        percentLabel.snp.makeConstraints { make in
            make.leading.equalTo(percentIndexLabel.snp.trailing)
            make.bottom.equalTo(percentIndexLabel.snp.bottom).inset(1.5)
            make.trailing.equalToSuperview()
        }
        
        completeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(percentLabel.snp.bottom).inset(completeBottomIndent)
            make.centerX.equalToSuperview()
        }
        
        toGoLabel.snp.makeConstraints { make in
            make.top.equalTo(completeLabel.snp.bottom).inset(toGoTopIndent)
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupMaintainConstraints() {
        weightDiffLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
        }
    }
}
    
// MARK: - Caclulate indents
extension GoalsCircleProgressView {
    
    private func calculateIndents() {
        calculateToGoTopIndent()
        calculateCompleteBottomIndent()
        calculatePercentContTopIndent()
    }
    
    private func calculateToGoTopIndent() {
        if !isGoalSplit && viewType == .smallSplit {
            toGoTopIndent = -6
        } else if viewType == .smallSplit && (UIDevice.screenType == .less || UIDevice.screenType == .x812 || UIDevice.screenType == .x844 || UIDevice.screenType == .x852) {
            toGoTopIndent = -4
        } else if viewType == .smallSplit && (UIDevice.screenType == .x896 || UIDevice.screenType == .x926 || UIDevice.screenType == .x932) {
            toGoTopIndent = -12
        } else {
            toGoTopIndent = -10
        }
    }
    
    private func calculateCompleteBottomIndent() {
        (viewType == .smallSplit && isGoalSplit) ? (completeBottomIndent = -12) : (completeBottomIndent = -18)
    }
    
    private func calculatePercentContTopIndent() {
        if viewType == .smallSplit && (UIScreen.main.bounds.width <= 375) && isGoalSplit {
            percentConteinerTopIndent = 12
        } else if viewType == .smallSplit && !isGoalSplit {
            percentConteinerTopIndent = 30
        } else if viewType == .smallSplit {
            percentConteinerTopIndent = 18
        } else {
            percentConteinerTopIndent = 36
        }
    }
}
