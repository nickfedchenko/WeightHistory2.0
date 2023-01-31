//
//  EmptyBodyHistoryTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class EmptyBodyHistoryTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: EmptyBodyHistoryTableViewCell.self)
    
    // MARK: - Property list
    var isFirstCell = true
    private var emptyDataLabel = UILabel()
    private var seporatorView = UIView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(for type: MeasurementTypes, with index: Int) {
        configureDateLabel(for: type, with: index)
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureSeporatorView()
    }
    
    private func addSubViews() {
        contentView.addSubview(emptyDataLabel)
        contentView.addSubview(seporatorView)
    }
    
    private func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func configureSeporatorView() {
        seporatorView.backgroundColor = .seporatorColor
    }
    
    private func configureDateLabel(for type: MeasurementTypes, with index: Int) {
        emptyDataLabel.textAlignment = .left
        emptyDataLabel.font = R.font.openSansMedium(size: 17)
        emptyDataLabel.textColor = type.color
        if index == 0 {
            emptyDataLabel.text = R.string.localizable.measurementHistoryNothingLogget()
        } else {
            emptyDataLabel.text = ""
        }
    }
}

// MARK: - Constraints
extension EmptyBodyHistoryTableViewCell {
    
    private func setupConstraints() {
        
        emptyDataLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(8.5)
            make.bottom.equalTo(seporatorView.snp.top).inset(-8.5)
        }
        
        seporatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
}
