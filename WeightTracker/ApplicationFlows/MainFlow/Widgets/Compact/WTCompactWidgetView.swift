//
//  WTCompactWidgetView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class WTCompactWidgetView: UIView {
    
    // MARK: - Property list
    private var widgetNameLabel = UILabel()
    private var lastMeasurementLabel = UILabel()
    private var backgroundImageView = UIImageView()
    private var widgetScaleImageView = UIImageView()
    
    var widgetType: MeasurementTypes = .chest {
        didSet {
            configureWidgetNameLabel()
            configureBackgroundsImageView()
        }
    }
    var onWidgetPressed: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UPDATE
    func updateLastMeasurement(with lastMeasurement: String) {
        configureLastMeasurementLabel(with: lastMeasurement)
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureWidgetNameLabel()
        configureBackgroundsImageView()
        configureViewTapGesture()
    }
    
    private func addSubViews() {
        addSubview(backgroundImageView)
        addSubview(widgetNameLabel)
        addSubview(lastMeasurementLabel)
        addSubview(widgetScaleImageView)
    }
    
    private func configureView() {
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.20
        layer.masksToBounds = false
    }
    
    private func configureWidgetNameLabel() {
        widgetNameLabel.textAlignment = .left
        widgetNameLabel.attributedText = NSMutableAttributedString(string: widgetType.title, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
            NSAttributedString.Key.foregroundColor: widgetType.color.cgColor
        ])
    }
    
    private func configureLastMeasurementLabel(with lastMeasurement: String) {
        lastMeasurementLabel.textAlignment = .left
        lastMeasurementLabel.attributedText = NSMutableAttributedString(string: lastMeasurement, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: widgetType.color.cgColor
        ])
    }
    
    private func configureBackgroundsImageView() {
        widgetScaleImageView.contentMode = .scaleToFill
        backgroundImageView.contentMode = .scaleToFill
        switch widgetType {
        case .chest:
            backgroundImageView.image = R.image.chestWidgetBackground()
            widgetScaleImageView.image = R.image.chestScale()
        case .waist:
            backgroundImageView.image = R.image.waistWidgetBackground()
            widgetScaleImageView.image = R.image.waistScale()
        case .hip:
            backgroundImageView.image = R.image.hipWidgetBackground()
            widgetScaleImageView.image = R.image.hipScale()
        case .weight:
            return
        case .bmi:
            return
        }
    }

    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onWidgetTap))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func onWidgetTap() {
        HapticFeedback.medium.vibrate()
        onWidgetPressed?()
    }
}

// MARK: - Setup constraints
extension WTCompactWidgetView {
    
    private func setupConstraints() {
        
        widgetNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(12)
            make.height.equalTo(30)
        }
        
        lastMeasurementLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        widgetScaleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
