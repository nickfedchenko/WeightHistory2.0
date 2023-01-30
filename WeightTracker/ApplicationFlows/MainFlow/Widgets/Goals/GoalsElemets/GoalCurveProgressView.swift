//
//  GoalCurveProgressView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class GoalCurveProgressView: UIView {
    
    // MARK: - Property list
    private var completedStepsLabel = UILabel()
    private var milestonesLabel = UILabel()
    
    private var progressIndex: Double = 0
    private var stepsIndex = 0
    private var currnetStepIndex = 0
    private var topCompletedStepsInset: CGFloat = 0
    private var bottomMilestonesInset: CGFloat = 0
    
    // MARK: - Overrides
    override func draw(_ rect: CGRect) {
        drawBackgroundCurve(rect: rect)
        drawProgressCurve(rect: rect, progress: progressIndex)
        drawLastDot(rect: rect)
        drawDots(rect: rect)
        calculateInsets(rect: rect)
        setupConstarints()
    }
    
    // MARK: - Public methods
    func configure(progress: Double, steps: Int, currentStep: Int) {
        progressIndex = progress
        stepsIndex = steps
        currnetStepIndex = currentStep
        configureUI()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubviews()
        configureCompletedStepsLabel()
        configureMilestonesLabel()
    }
    
    private func addSubviews() {
        addSubview(completedStepsLabel)
        addSubview(milestonesLabel)
    }
    
    private func configureCompletedStepsLabel() {
        let text = "\(currnetStepIndex)" + R.string.localizable.milestoneOf() + "\(stepsIndex)"
        completedStepsLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configureMilestonesLabel() {
        milestonesLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneMilestones(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    // MARK: - Drawing methods
    private func drawProgressCurve(rect: CGRect, progress: CGFloat) {
        if progress <= 1 {
            layer.addSublayer(getProgressLayers(rect: rect, progress: progress))
        } else {
            layer.addSublayer(getProgressLayers(rect: rect, progress: 1))
            layer.addSublayer(getProgressLayers(rect: rect, progress: progress.truncatingRemainder(dividingBy: 1)))
        }
    }
    
    private func drawBackgroundCurve(rect: CGRect) {
        let shape = getProgressLayers(rect: rect, progress: 1)
        shape.strokeColor = UIColor.milestoneUnselectedColor.cgColor
        shape.zPosition = -1
        layer.addSublayer(shape)
    }
    
    
    private func drawLastDot(rect: CGRect) {
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(x: rect.width - 4, y: rect.height - 4),
            radius: 4,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        if currnetStepIndex == stepsIndex {
            shapeLayer.fillColor = UIColor.weightPrimary.cgColor
        } else {
            shapeLayer.fillColor = UIColor.milestoneUnselectedColor.cgColor
        }
        layer.addSublayer(shapeLayer)
    }
    

    
    private func getProgressLayers(rect: CGRect, progress: CGFloat) -> CAShapeLayer {
        let spacing: CGFloat = 4
        let rectShape = CGRect(
            x: spacing,
            y: spacing,
            width: rect.width - 2 * spacing,
            height: rect.height - 2 * spacing
        )
                
        let prLayer = getLineShape(rect: rectShape)
        prLayer.strokeEnd = progress
        
        
        return prLayer
    }
    
    private func drawDots(rect: CGRect) {
        let spacing: CGFloat = 4
        let rectShape = CGRect(
            x: spacing,
            y: spacing,
            width: rect.width - 2 * spacing,
            height: rect.height - 2 * spacing
        )
        
        let progressCoeff = Double(1) / Double(stepsIndex)
        let end = 0.0005
        for i in 0...stepsIndex {
            let prLayer = getDotShape(rect: rectShape)
            prLayer.strokeStart = progressCoeff * Double(i)
            prLayer.strokeEnd = progressCoeff * Double(i) + end
            
            
            if i == 0 {
                prLayer.strokeColor = UIColor.weightPrimary.cgColor
            } else if i <= currnetStepIndex {
                prLayer.strokeColor = UIColor.weightPrimary.cgColor
            } else {
                prLayer.strokeColor = UIColor.milestoneUnselectedColor.cgColor

            }
            layer.addSublayer(prLayer)
        }
        
    }
    
    private func getDotShape(rect: CGRect) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = getPath(rect: rect).cgPath
        shape.lineWidth = 8
        shape.lineCap = .round
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }
    
    private func getLineShape(rect: CGRect) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = getPath(rect: rect).cgPath
        shape.lineWidth = 2
        shape.strokeColor = UIColor.weightPrimary.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        return shape
    }
    
    private func getPath(rect: CGRect) -> UIBezierPath {
        let radius: CGFloat = rect.height / 4.0
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to: CGPoint(
            x: rect.origin.x + rect.width - radius,
            y: rect.origin.y
        ))
        path.addArc(
            withCenter: CGPoint(
                x: rect.origin.x + rect.width - radius,
                y: rect.origin.y + radius
            ),
            radius: radius,
            startAngle: -.pi / 2.0,
            endAngle: .pi / 2.0,
            clockwise: true
        )
        path.addLine(to: CGPoint(
            x: rect.origin.x + radius,
            y: rect.origin.y + 2 * radius
        ))
        path.addArc(
            withCenter: CGPoint(
                x: rect.origin.x + radius,
                y: rect.origin.y + 3 * radius
            ),
            radius: radius,
            startAngle: -CGFloat.pi / 2.0,
            endAngle: CGFloat.pi / 2.0,
            clockwise: false
        )
        path.addLine(to: CGPoint(
            x: rect.maxX,
            y: rect.maxY
        ))
        
        return path
    }
}

// MARK: - Constraints
extension GoalCurveProgressView {
    
    private func calculateInsets(rect: CGRect) {
        topCompletedStepsInset = rect.height / 3.5
        bottomMilestonesInset = rect.height - (rect.height / 3.5)
    }
    
    private func setupConstarints() {
        
        completedStepsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(topCompletedStepsInset)
        }
        
        milestonesLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(bottomMilestonesInset)
        }
    }
}
