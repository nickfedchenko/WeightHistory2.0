//
//  GoalsTableViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

enum GoalsCellState {
    case completedState
    case nextStepState
    case notCompletedState
    case offState
}

final class GoalsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: GoalsTableViewCell.self)
    
    // MARK: - Property list
    private var goalsCircleView = UIView()
    private var goalsLabel = UILabel()
    private var goalsIndexLabel = UILabel()
    
    var cellState: GoalsCellState = .completedState {
        didSet {
            configureView()
            configureMilestoneCircleView()
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(mileText: String, indexText: String) {
        configureMilestoneLabel(text: mileText)
        configureGoalsIndexLabel(text: indexText)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureMilestoneCircleView()
    }
    
    private func addSubViews() {
        contentView.addSubview(goalsCircleView)
        contentView.addSubview(goalsLabel)
        contentView.addSubview(goalsIndexLabel)
    }
    
    private func configureView() {
        selectionStyle = .none
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        
        if cellState == .nextStepState {
            layer.backgroundColor = UIColor.milestoneMainColor.cgColor
        } else {
            layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    private func configureMilestoneCircleView() {
        goalsCircleView.layer.cornerRadius = 4
        goalsCircleView.layer.cornerCurve = .continuous
        
        if cellState == .completedState {
            goalsCircleView.backgroundColor = .weightPrimary
        } else {
            goalsCircleView.backgroundColor = .milestoneUnselectedColor
        }
    }
    
    private func configureMilestoneLabel(text: String) {
        var textColor = UIColor.white.cgColor
        goalsLabel.textAlignment = .left
        
        switch cellState {
        case .completedState:
            textColor = UIColor.milestoneMainColor.cgColor
        case .nextStepState:
            textColor = UIColor.white.cgColor
        case .notCompletedState:
            textColor = UIColor.milestoneMainColor.cgColor
        case .offState:
            textColor = UIColor.milestoneUnselectedColor.cgColor
        }
        
        goalsLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: textColor
        ])
    }
    
    private func configureGoalsIndexLabel(text: String) {
        var textColor = UIColor.red.cgColor
        goalsIndexLabel.textAlignment = .right

        switch cellState {
        case .completedState:
            textColor = UIColor.weightPrimary.cgColor
        case .nextStepState:
            textColor = UIColor.white.cgColor
        case .notCompletedState:
            textColor = UIColor.milestoneMainColor.cgColor
        case .offState:
            textColor = UIColor.milestoneUnselectedColor.cgColor
        }
        
        goalsIndexLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansBold(size: 15) ?? UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: textColor
        ])
    }
}

// MARK: - Constraints
extension GoalsTableViewCell {
    
    private func setupConstraints() {
        
        goalsCircleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(9)
            make.top.bottom.equalToSuperview().inset(10)
            make.height.equalTo(8)
            make.width.equalTo(8)
        }
        
        goalsLabel.snp.makeConstraints { make in
            make.leading.equalTo(goalsCircleView.snp.trailing).inset(-13)
            make.centerY.equalTo(goalsCircleView.snp.centerY)
        }
        
        goalsIndexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.centerY.equalTo(goalsCircleView.snp.centerY)
        }
    }
}

