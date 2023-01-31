//
//  ActionButton.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

final class ActionButton: UIButton {
    
    // MARK: - Property list
    var isMainState = true
    
    // MARK: - Overrides properies
    override public var isHighlighted: Bool {
        didSet {
            if !isMainState && isHighlighted {
                layer.backgroundColor = UIColor.weightPrimary.cgColor
                setTitleColor(.white, for: .highlighted)
            } else {
                if !isMainState {
                    layer.backgroundColor = UIColor.white.cgColor
                    setTitleColor(.weightPrimary, for: .highlighted)
                }
            }
        }
    }
    
    // MARK: - Public methods
    func makeMainState(isForSmallState: Bool = false) {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        titleLabel?.font = FontService.shared.localFont(size: isForSmallState ? Locale.isLanguageRus ? 14 : 20 : 20, bold: true)
        isEnabled = true
        
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = UIColor.weightPrimary.cgColor
        layer.borderWidth = 0
        isMainState = true
        
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.49
        layer.masksToBounds = false
    }
    
    func makeBodyWidgetState(for type: MeasurementTypes) {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        isEnabled = true

        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = type.color.cgColor
        layer.borderWidth = 0
        isMainState = true

        layer.shadowColor = type.color.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.49
        layer.masksToBounds = false
    }
    
    func makeWhiteState(isForSmallState: Bool = false) {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        setTitleColor(.weightPrimary, for: .normal)
        setTitleColor(.white, for: .highlighted)
        titleLabel?.font = R.font.promptBold(size: isForSmallState ? Locale.isLanguageRus ? 14 : 20 : 20)
        isEnabled = true

        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderWidth = 0
        
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.49
        layer.masksToBounds = false
        isMainState = false
    }
    
    func makeDisableState() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        titleLabel?.font = R.font.promptBold(size: 20)

        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = UIColor.buttonDisable.cgColor
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    func makeDisableBorderState(isForSmallState: Bool = false) {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        titleLabel?.font = R.font.promptBold(size: isForSmallState ? Locale.isLanguageRus ? 14 : 20 : 20)

        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    func makeAddMeasurementState(with type: MeasurementTypes) {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        titleLabel?.font = R.font.promptSemiBold(size: 20)
        isEnabled = true

        clipsToBounds = true
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.backgroundColor = type.color.cgColor
        if type == .weight {
            layer.borderWidth = 1
            layer.borderColor = UIColor.saveButtonBorderColor.cgColor
        }
        isMainState = true

        layer.shadowColor = type.color.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 8)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.49
        layer.masksToBounds = false
    }
    
    // MARK: - Private methods
    private func drawShadows() {
        let path =  UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        let firstShadowLayer = CAShapeLayer()
        let secondShadowLayer = CAShapeLayer()
        let thirdShadowLayer = CAShapeLayer()
        
        firstShadowLayer.shadowPath = path
//        firstShadowLayer.backgroundColor = UIColor.weightPrimary.cgColor
//        firstShadowLayer.cornerRadius = 16
//        firstShadowLayer.cornerCurve = .continuous
        firstShadowLayer.shadowColor = UIColor.buttonShadowColor.cgColor
        firstShadowLayer.shadowOffset = CGSize(width: 0, height: 0.8)
        firstShadowLayer.shadowRadius = 2.06
        firstShadowLayer.shadowOpacity = 0.1
        firstShadowLayer.masksToBounds = false
        
        secondShadowLayer.shadowPath = path
        secondShadowLayer.shadowColor = UIColor.buttonShadowColor.cgColor
        secondShadowLayer.shadowOffset = CGSize(width: 0, height: 2.68)
        secondShadowLayer.shadowRadius = 6.92
        secondShadowLayer.shadowOpacity = 0.2
        secondShadowLayer.masksToBounds = false


        thirdShadowLayer.shadowPath = path
        thirdShadowLayer.shadowColor = UIColor.buttonShadowColor.cgColor
        thirdShadowLayer.shadowOffset = CGSize(width: 0, height: 12)
        thirdShadowLayer.shadowRadius = 31
        thirdShadowLayer.shadowOpacity = 0.49
        thirdShadowLayer.masksToBounds = false

        
        layer.insertSublayer(firstShadowLayer, at: 0)
        layer.insertSublayer(secondShadowLayer, at: 0)
        layer.insertSublayer(thirdShadowLayer, at: 0)
    }
}
