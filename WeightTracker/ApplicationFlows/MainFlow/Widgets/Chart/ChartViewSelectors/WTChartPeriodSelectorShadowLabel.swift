//
//  WTChartPeriodSelectorShadowLabel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartPeriodSelectorShadowLabel: UIView {
    
    // MARK: - Properties
    var isFirstDraw = true
    
    let shadowLayerBottom = CAShapeLayer()
    let shadowLayerMiddle = CAShapeLayer()
    let mainShadowLayer = CAShapeLayer()
    
    var shadowColor: UIColor = .chartPeriodSelectorShadowColor
    var borderColor: UIColor = .chartPeriodSelectorBorderColor
    
    private let selectorName: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.periodsWeek().capitalized
        label.textColor = .textPrimaryBlueColor
//        label.font = R.font.promptSemiBold(size: 13)
        label.font = FontService.shared.localFont(size: 13, bold: false)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Overrides
    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawShapeAndLayer()
    }
    
    // MARK: - Init
    init(shadowColor: UIColor = .chartPeriodSelectorShadowColor, borderColor: UIColor = .chartPeriodSelectorBorderColor) {
        self.shadowColor = shadowColor
        self.borderColor = borderColor
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Publick methods
    func setNewTextColor(color: UIColor) {
        selectorName.textColor = color
    }
    
    func setNewTitle(text: String) {
        selectorName.text = text
    }
    
    // MARK: - Private methods
    private func setupSubviews() {
        addSubview(selectorName)
        selectorName.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func drawShapeAndLayer() {
        guard isFirstDraw else { return }
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: bounds.width, height: 28)), cornerRadius: 4)
        mainShadowLayer.path = path.cgPath
        mainShadowLayer.strokeColor = UIColor(hex: "A78A74").cgColor
        mainShadowLayer.lineWidth = 1
        mainShadowLayer.fillColor = UIColor(hex: "FEF4EC").cgColor
        mainShadowLayer.shadowPath = path.cgPath
        mainShadowLayer.shadowColor = UIColor(hex: "C38D61").cgColor
        mainShadowLayer.shadowOpacity = 0.3
        mainShadowLayer.shadowOffset = CGSize(width: 0, height: 6)
        mainShadowLayer.shadowRadius = 8
        layer.insertSublayer(mainShadowLayer, at: 0)
        shadowLayerMiddle.shadowPath = path.cgPath
        shadowLayerMiddle.shadowColor = UIColor(hex: "C38D61").cgColor
        shadowLayerMiddle.shadowOpacity = 0.05
        shadowLayerMiddle.shadowOffset = CGSize(width: 0, height: 2.68)
        shadowLayerMiddle.shadowRadius = 6
        layer.insertSublayer(shadowLayerMiddle, at: 0)
        shadowLayerBottom.shadowPath = path.cgPath
        shadowLayerBottom.shadowColor = UIColor(hex: "C38D61").cgColor
        shadowLayerBottom.shadowOpacity = 0.1
        shadowLayerBottom.shadowOffset = CGSize(width: 0, height: 0.8)
        shadowLayerBottom.shadowRadius = 4
        isFirstDraw.toggle()
    }
}
