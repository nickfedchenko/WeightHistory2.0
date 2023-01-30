//
//  GoalsLineProgressView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class GoalsLineProgressView: UIView {
    
    // MARK: - Property list
    var progress = 0.5
    var steps = 10
    var currentStepIndex = 0
    var isGoalSplit = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawingMainLine(rect: rect)
        drawingCircles(rect: rect)
    }
    
    // MARK: - Private methods
    private func drawingMainLine(rect: CGRect) {
        let backgroundMask = CAShapeLayer()
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: 0).cgPath
        layer.mask = backgroundMask
        
        let progressRect = CGRect(origin: CGPoint(x: 0, y: 3), size: CGSize(width: (rect.width * progress) - 4, height: rect.height / 4))
        let progressLayer = CALayer()
        progressLayer.frame = progressRect
        
        let otherRect = CGRect(origin: CGPoint(x: (rect.width * progress) - 4, y: 3), size: CGSize(width: rect.width - (rect.width * progress), height: rect.height / 4))
        let otherLayer = CALayer()
        otherLayer.frame = otherRect
        
        layer.addSublayer(progressLayer)
        layer.addSublayer(otherLayer)
        
        if !isGoalSplit {
            progressLayer.backgroundColor = UIColor.milestoneUnselectedColor.cgColor
        } else {
            progressLayer.backgroundColor = UIColor.weightPrimary.cgColor
        }
        otherLayer.backgroundColor = UIColor.milestoneUnselectedColor.cgColor
    }
    
    private func drawingCircles(rect: CGRect) {
        let cirlceRadius: CGFloat = 4
        let coeff = (rect.width - (cirlceRadius * 2)) / CGFloat(steps)
        
        for i in 0...steps {
            
            var xPos = (coeff * CGFloat(i)) + cirlceRadius

            if i == steps {
                xPos = rect.width - cirlceRadius
            }
            
            let circlePath = UIBezierPath(
                arcCenter: CGPoint(x: xPos, y: cirlceRadius),
                radius: CGFloat(cirlceRadius),
                startAngle: CGFloat(0),
                endAngle: CGFloat(Double.pi * 2),
                clockwise: true)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            
            if isGoalSplit {
                currentStepIndex >= i ? (shapeLayer.fillColor = UIColor.weightPrimary.cgColor) : (shapeLayer.fillColor = UIColor.milestoneUnselectedColor.cgColor)
            } else {
                shapeLayer.fillColor = UIColor.milestoneUnselectedColor.cgColor
            }
            
            layer.addSublayer(shapeLayer)
        }
    }
}
