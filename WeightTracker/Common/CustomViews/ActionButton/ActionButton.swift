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
        titleLabel?.font = FontService.shared.localFont(size: isForSmallState ? Locale.isLanguageRus ? 14 : 20 : 20, bold: true)
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
        titleLabel?.font = FontService.shared.localFont(size: 20, bold: true)

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
        titleLabel?.font = FontService.shared.localFont(size: isForSmallState ? Locale.isLanguageRus ? 14 : 20 : 20, bold: true)

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
        titleLabel?.font = FontService.shared.localFont(size: 20, bold: false)
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
}
