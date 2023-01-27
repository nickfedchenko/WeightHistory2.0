//
//  WTLastDotView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTLastDotView: UIView {
    
    // MARK: - Properties
    private let innerCircle: UIView = {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.height.equalTo(4)
        }
        view.layer.cornerRadius = 2
        return view
    }()
    
    var commonColor: UIColor? {
        didSet {
            innerCircle.backgroundColor = commonColor
            layer.borderColor = commonColor?.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 8
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup subviews
    private func setupSubviews() {
        addSubview(innerCircle)
        
        innerCircle.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
}
