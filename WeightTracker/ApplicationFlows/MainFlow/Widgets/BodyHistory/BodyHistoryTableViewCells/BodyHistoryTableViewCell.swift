//
//  BodyHistoryTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class BodyHistoryTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: BodyHistoryTableViewCell.self)
    
    // MARK: - Property list
    private var dateLabel = UILabel()
    private var measurementLabel = UILabel()
    private var seporatorView = UIView()
    private let hkIcon = UIImageView(image: R.image.hkIcon())
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        hkIcon.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(for type: MeasurementTypes, measurement: Double, date: Date, widthUnit: String, lengthUnit: String, isFromHK: Bool = false) {
        configureMeasurementLabel(for: type, with: measurement, widthUnit: widthUnit, lengthUnit: lengthUnit)
        configureDateLabel(for: type, with: date)
        hkIcon.alpha = isFromHK ? 1 : 0
    }
    
    func configureWithPeriod(for type: MeasurementTypes, measurement: String, date: String, widthUnit: String, lengthUnit: String) {
        configureMeasurementLabelWithString(for: type, with: measurement, widthUnit: widthUnit, lengthUnit: lengthUnit)
        configureDateLabelWithString(for: type, with: date)
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        configureView()
        configureSeporatorView()
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(measurementLabel)
        contentView.addSubview(seporatorView)
        contentView.addSubview(hkIcon)
    }
    
    private func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func configureSeporatorView() {
        seporatorView.backgroundColor = .seporatorColor
    }
    
    // MARK: - SETUP LABELS
    private func configureMeasurementLabel(for type: MeasurementTypes, with measurement: Double, widthUnit: String, lengthUnit: String) {
        measurementLabel.textAlignment = .right
        var string = ""
        
        switch type {
        case .chest:    string = ("\(measurement)")
        case .waist:    string = ("\(measurement)")
        case .hip:      string = ("\(measurement)")
        case .weight:   string = ("\(String(format: "%.1f", measurement))")
        case .bmi:      return
        }
        
        measurementLabel.attributedText = NSMutableAttributedString(
            string: string,
            attributes: [
                NSAttributedString.Key.foregroundColor: type.color,
                NSAttributedString.Key.font: R.font.openSansBold(size: 17) ?? UIFont.systemFont(ofSize: 17)
            ]
        )
    }
    
    private func configureMeasurementLabelWithString(for type: MeasurementTypes, with measurement: String, widthUnit: String, lengthUnit: String) {
        measurementLabel.textAlignment = .right
        var string = ""
        
        switch type {
        case .chest:    string = ("\(measurement)")
        case .waist:    string = ("\(measurement)")
        case .hip:      string = ("\(measurement)")
        case .weight:   string = ("\(measurement)")
        case .bmi:      return
        }
        
        measurementLabel.attributedText = NSMutableAttributedString(
            string: string,
            attributes: [
                NSAttributedString.Key.foregroundColor: type.color,
                NSAttributedString.Key.font: R.font.openSansBold(size: 17) ?? UIFont.systemFont(ofSize: 17)
            ]
        )
    }
    
    private func configureDateLabel(for type: MeasurementTypes, with date: Date) {
        dateLabel.textAlignment = .left
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let formDate = formatter.string(from: date)
        dateLabel.attributedText = NSMutableAttributedString(
            string: formDate,
            attributes: [
                NSAttributedString.Key.foregroundColor: type.color,
                NSAttributedString.Key.font: R.font.openSansMedium(size: 17) ?? UIFont.systemFont(ofSize: 17)
            ]
        )
    }
    
    private func configureDateLabelWithString(for type: MeasurementTypes, with date: String) {
        dateLabel.textAlignment = .left
        dateLabel.attributedText = NSMutableAttributedString(
            string: date,
            attributes: [
                NSAttributedString.Key.foregroundColor: type.color,
                NSAttributedString.Key.font: R.font.openSansMedium(size: 17) ?? UIFont.systemFont(ofSize: 17)
            ]
        )
    }
}

// MARK: - Constraints
extension BodyHistoryTableViewCell {
    
    private func setupConstraints() {
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(8.5)
            make.bottom.equalTo(seporatorView.snp.top).inset(-8.5)
        }
        
        seporatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        measurementLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(8.5)
            make.bottom.equalTo(seporatorView.snp.top).inset(-8.5)
        }
        
        hkIcon.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(measurementLabel.snp.leading).inset(-8)
        }
    }
}
