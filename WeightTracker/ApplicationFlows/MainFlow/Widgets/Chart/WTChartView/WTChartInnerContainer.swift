//
//  WTChartInnerContainer.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartInnerContainer: UIView {
    
    // MARK: - Properties
    private var drawingData: WTChartViewModel.WTChartDrawInstructions! {
        didSet {
            clearDrawings()
            updateChart()
        }
    }
    
    private var points: [UIView] = []
    private var hAxis: [CAShapeLayer] = []
    private var vAxis: [CAShapeLayer] = []
    private var isFistShow: Bool = true
    
    // MARK: - Publick methods
    func setData(dataSet: WTChartViewModel.WTChartDrawInstructions) {
        drawingData = dataSet
    }
    
    // MARK: - UPDATE CHART
    private func updateChart() {
        drawHorizontalAxis(for: drawingData)
        drawVerticalAxis(for: drawingData)
        drawGradient()
        drawControlPoints()
        drawCurve()
    }
    
    // MARK: - DRAWING METHODS
    private func clearDrawings() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    private func drawGradient() {
        guard drawingData.innerContainerDrawingData.controlPoints.count > 1 else { return }
        let dataPoints = drawingData.innerContainerDrawingData.controlPoints
        let color = drawingData.innerContainerDrawingData.color
        let colors = [color, color.withAlphaComponent(0.4344), color.withAlphaComponent(0)]
            let path = UIBezierPath()
            path.move(to: CGPoint(x: dataPoints[0].x, y: bounds.height))
            path.addLine(to: dataPoints[0])
            
            if let curvedPath = CurveChartAlgorithm.shared.createCurvedPath(dataPoints) {
                path.append(curvedPath)
            }
            
        path.addLine(to: CGPoint(x: dataPoints[dataPoints.count-1].x, y: bounds.height - drawingData.innerContainerDrawingData.verticalInset))
            path.addLine(to: CGPoint(x: dataPoints[0].x, y: bounds.height - drawingData.innerContainerDrawingData.verticalInset))
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
        maskLayer.frame.size.width = 0
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.clear.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
      
            let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds

        layer.addSublayer(gradientLayer)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.mask = maskLayer
        let animator = CABasicAnimation(keyPath: "fillColor")
        animator.fromValue = UIColor.clear.cgColor
        animator.toValue = UIColor.white.cgColor
        animator.duration = 0.3
        maskLayer.add(animator, forKey: "fillColor")
        maskLayer.fillColor =  UIColor.white.cgColor
    }
    
    private func drawCurve() {
        guard drawingData.innerContainerDrawingData.controlPoints.count > 1 else {
            return
        }
       let path = CurveChartAlgorithm.shared.createCurvedPath(drawingData.innerContainerDrawingData.controlPoints)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = path?.cgPath
        shapeLayer.strokeColor = drawingData.innerContainerDrawingData.color.cgColor
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
        let animator = CABasicAnimation(keyPath: "strokeEnd")
        animator.duration = 0.5
        animator.fromValue = 0
        animator.toValue = 1
        animator.isRemovedOnCompletion = false
        shapeLayer.add(animator, forKey: "strokeEnd")
        shapeLayer.strokeEnd = 1
    }
    
    private func drawControlPoints() {
        for (index, controlPoint) in drawingData.innerContainerDrawingData.controlPoints.enumerated() {
            var view: UIView
            if index == drawingData.innerContainerDrawingData.controlPoints.count - 1 {
                view = WTLastDotView()
                view.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
                (view as? WTLastDotView)?.commonColor = drawingData.innerContainerDrawingData.color
            } else {
                view = UIView()
                view.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
                view.layer.cornerRadius = 2
                view.backgroundColor = drawingData.innerContainerDrawingData.color
            }
            
            view.center = controlPoint
            if isFistShow {
                view.center.y = -200
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.6) {
                        view.center.y = controlPoint.y
                    }
                isFistShow.toggle()
            }
            addSubview(view)
            points.append(view)
            
        }
    }
    
    private func drawHorizontalAxis(for model: WTChartViewModel.WTChartDrawInstructions) {
        guard hAxis.isEmpty else {
            guard let drawingData = drawingData else { return }
            hAxis.forEach {
                let animator = CABasicAnimation(keyPath: "fillColor")
                animator.fromValue = $0.fillColor
                animator.duration = 0.3
                animator.toValue = drawingData.innerContainerDrawingData.color.cgColor
                $0.add(animator, forKey: "fillColor")
                $0.fillColor = drawingData.innerContainerDrawingData.color.cgColor
            }
            return
        }
        for controlPoint in model.innerContainerDrawingData.hAxisYcoordinates {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(
                x: 0, y: controlPoint, width: model.innerContainerDrawingData.hAxisWidth, height: 1
            )
            let path = UIBezierPath(rect: shapeLayer.bounds)
            shapeLayer.fillColor = UIColor(hex: "FDD9BC").cgColor
            let animation = CABasicAnimation()
            animation.duration = 0.6
            animation.keyPath = "path"
            animation.fromValue = CGPath(rect: .zero, transform: .none)
            animation.toValue = path.cgPath
            animation.isRemovedOnCompletion = false
            shapeLayer.add(animation, forKey: "path")
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
        }
        
    }
    
    private func drawVerticalAxis(for model: WTChartViewModel.WTChartDrawInstructions) {
        for controlPoint in model.innerContainerDrawingData.vAxisXcoordinates {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(
                x: controlPoint, y: 0, width: 1, height: model.innerContainerDrawingData.vAxisHeight
            )
            let path = UIBezierPath(rect: shapeLayer.bounds)
            shapeLayer.fillColor = UIColor(hex: "FDD9BC").cgColor
            let animation = CABasicAnimation()
            animation.duration = 0.6
            animation.keyPath = "path"
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = CGPath(rect: .zero, transform: .none)
            animation.toValue = path.cgPath
            animation.isRemovedOnCompletion = false
            shapeLayer.add(animation, forKey: "path")
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
        }
    }
}
