//
//  ShadowCellView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit

final class ShadowCellView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() -> Void {
        layer.masksToBounds = false
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.2
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var r = bounds
        r.origin.y += 31
        layer.shadowPath = UIBezierPath(roundedRect: r, cornerRadius: 16).cgPath
    }
}
