//
//  GoalsWidgetView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

enum GoalsWidgetState {
    case unsplitGoal
    case splitGoal
    case maintaineWeight
}

final class GoalsWidgetView: UIView {
    
    // MARK: - Property list
    private var widgetTitleLabel = UILabel()
    private var overallLabel = UILabel()
    private var goalCircleProgressView = GoalsCircleProgressView()
    private var goalCurveProgressView = GoalCurveProgressView()
    private var stackForTopLabels = UIStackView()
    private var stackForBotLabels = UIStackView()
    private var startLabel = UILabel()
    private var nowLabel = UILabel()
    private var goalLabel = UILabel()
    private var startIndexLabel = UILabel()
    private var nowIndexLabel = UILabel()
    private var goalIndexLabel = UILabel()
    
    private var viewModel = GoalsViewModel()
    
    var widgetType: GoalsWidgetState = .splitGoal
    
    // MARK: - Insets
    private var topCircleProgressIndent: CGFloat = 0
    private var topCurveProgressIndent: CGFloat = 0
    private var sidesCurveProgressIndent: CGFloat = 0
    private var bottomCurveProgressIndent: CGFloat = 0
    private var circleProgressHeight: CGFloat = 0
    
    // MARK: - Configuration
    func configure() {
        viewModel.configure()
        calculateInsets()
        configureWidgetType()
        configureUI()
    }
    
    func update() {
        viewModel.configure()
        configureWidgetTitleLabel()
        configureGoalCircleProgressView()
        configureGoalCurveProgressView()
        configureCompleteOverallLabel()
        configureStacksForLabels()
        configureStartNowGoalLabels()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureWidgetTitleLabel()
        configureGoalCircleProgressView()
        configureGoalCurveProgressView()
        configureCompleteOverallLabel()
        configureStacksForLabels()
        configureStartNowGoalLabels()
    }
    
    private func addSubViews() {
        addSubview(widgetTitleLabel)
        addSubview(goalCircleProgressView)
        addSubview(goalCurveProgressView)
        addSubview(overallLabel)
        addSubview(stackForTopLabels)
        addSubview(stackForBotLabels)
    }
    
    private func configureView() {
        backgroundColor = .clear
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.buttonShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 31
        layer.shadowOpacity = 0.20
        layer.masksToBounds = false
    }
    
    // MARK: - WIDGET TYPE CONFIGURATION
    private func configureWidgetType() {
        if viewModel.isUserMaintainWeight {
            widgetType = .maintaineWeight
        } else if viewModel.isSplitGoalSelected {
            widgetType = .splitGoal
        } else {
            widgetType = .unsplitGoal
        }
    }
    
    // MARK: - CONFIGURE PROGRESS VIEWS
    private func configureGoalCircleProgressView() {
        goalCircleProgressView.isGoalSplit = viewModel.isSplitGoalSelected
        if viewModel.isUserMaintainWeight {
            goalCircleProgressView.viewType = .smallMaintain
            goalCircleProgressView.progress = viewModel.weightDiffProgress
            goalCircleProgressView.configureMainTainState(weightDiffIndex: viewModel.userWeightDiff, weightUnit: viewModel.userWeightUnit)
        } else {
            goalCircleProgressView.viewType = .smallSplit
            if goalCircleProgressView.isGoalSplit {
                goalCircleProgressView.progress = viewModel.milestoneProgress / 100
                goalCircleProgressView.configure(percent: viewModel.milestoneProgress, weight: viewModel.mileStoneToGo, weightUnit: viewModel.userWeightUnit)
            } else {
                goalCircleProgressView.progress = viewModel.userWeightProgress
                goalCircleProgressView.configure(percent: roundHundred(viewModel.userWeightProgress * 100), weight: viewModel.overallToGo, weightUnit: viewModel.userWeightUnit)
            }
        }
    }
    
    private func configureGoalCurveProgressView() {
        viewModel.isSplitGoalSelected == true ? (goalCurveProgressView.isHidden = false) : (goalCurveProgressView.isHidden = true)
        goalCurveProgressView.configure(progress: viewModel.userWeightProgress, steps: viewModel.milestones,  currentStep: viewModel.currentStepIndex)
    }
    
    // MARK: - LABELS CONFIGURATION
    private func configureWidgetTitleLabel() {
        var text = ""
        viewModel.isSplitGoalSelected == true ? (text = R.string.localizable.milestoneMilestone() + "\(viewModel.nextStepIndex)") : (text = R.string.localizable.milestoneMyGoal())
        
        widgetTitleLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.promptSemiBold(size: 20) ?? UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configureCompleteOverallLabel() {
        viewModel.isSplitGoalSelected == true ? (overallLabel.isHidden = false) : (overallLabel.isHidden = true)
        overallLabel.numberOfLines = 0
        let text = "\(roundHundred(viewModel.userWeightProgress * 100))% " + R.string.localizable.milestoneCompleteOverall()
        overallLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
    }
    
    private func configureStacksForLabels() {
        if viewModel.isSplitGoalSelected {
            stackForTopLabels.isHidden = true
            stackForBotLabels.isHidden = true
        } else {
            stackForTopLabels.isHidden = false
            stackForBotLabels.isHidden = false
        }
        
        stackForTopLabels.axis = .horizontal
        stackForTopLabels.distribution = .equalSpacing
        stackForTopLabels.addArrangedSubview(startLabel)
        stackForTopLabels.addArrangedSubview(nowLabel)
        stackForTopLabels.addArrangedSubview(goalLabel)

        stackForBotLabels.axis = .horizontal
        stackForBotLabels.distribution = .equalSpacing
        stackForBotLabels.addArrangedSubview(startIndexLabel)
        stackForBotLabels.addArrangedSubview(nowIndexLabel)
        stackForBotLabels.addArrangedSubview(goalIndexLabel)
    }
    
    private func configureStartNowGoalLabels() {
        let startText = "\(viewModel.userStartWeight)"
        let nowtText = "\(viewModel.userCurrentWeight)"
        let goalText = "\(viewModel.userGoalWeight)"
        
        configureLabel(label: startIndexLabel, text: startText, size: 12, color: .milestoneMainColor)
        
        startLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneStart(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
        
        configureLabel(label: nowIndexLabel, text: nowtText, size: 12, color: .milestoneMainColor)
        nowLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneNow(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
        
        configureLabel(label: goalIndexLabel, text: goalText, size: 12, color: .milestoneMainColor)
        goalLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneGoal(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
    }
    
    // MARK: - Other private methods
    private func configureLabel(label: UILabel, text: String, size: CGFloat, color: UIColor) {
        label.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: size) ?? UIFont.systemFont(ofSize: size),
            NSAttributedString.Key.foregroundColor: color.cgColor
        ])
    }
}

// MARK: - Setup cpnstraints
extension GoalsWidgetView {
    
    private func setupConstraints() {
        
        widgetTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        goalCircleProgressView.snp.makeConstraints { make in
            make.height.equalTo(circleProgressHeight)
            make.width.equalTo(circleProgressHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(widgetTitleLabel.snp.bottom).inset(topCircleProgressIndent)
        }
        
        goalCurveProgressView.snp.makeConstraints { make in
            make.top.equalTo(goalCircleProgressView.snp.bottom).inset(topCurveProgressIndent)
            make.bottom.equalTo(overallLabel.snp.top).inset(bottomCurveProgressIndent)
            make.leading.trailing.equalToSuperview().inset(sidesCurveProgressIndent)
        }
        
        overallLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        stackForBotLabels.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(19)
            make.bottom.equalToSuperview().inset(16)
        }
        
        stackForTopLabels.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(stackForBotLabels.snp.top)
        }
    }
    
    
    private func calculateInsets() {
        switch UIDevice.screenType {
        case .x932:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = -5) : (topCircleProgressIndent = -48)
            sidesCurveProgressIndent = 29
            topCurveProgressIndent = -40
            bottomCurveProgressIndent = -21
        case .x926:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = -5) : (topCircleProgressIndent = -48)
            sidesCurveProgressIndent = 29
            topCurveProgressIndent = -40
            bottomCurveProgressIndent = -21
        case .x896:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = -5) : (topCircleProgressIndent = -36)
            sidesCurveProgressIndent = 28
            topCurveProgressIndent = -25
            bottomCurveProgressIndent = -18
        case .x852:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = -5) : (topCircleProgressIndent = -16)
            sidesCurveProgressIndent = 26
            topCurveProgressIndent = -10
            bottomCurveProgressIndent = -5
        case .x844:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = -5) : (topCircleProgressIndent = -16)
            sidesCurveProgressIndent = 26
            topCurveProgressIndent = -10
            bottomCurveProgressIndent = -5
        case .x812:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = 0) : (topCircleProgressIndent = -5)
            sidesCurveProgressIndent = 25
            topCurveProgressIndent = 3
            bottomCurveProgressIndent = -2
        case .less:
            viewModel.isSplitGoalSelected == true ? (topCircleProgressIndent = 0) : (circleProgressHeight = -5)
            sidesCurveProgressIndent = 25
            topCurveProgressIndent = 3
            bottomCurveProgressIndent = -2
        }
        
        if !viewModel.isSplitGoalSelected {
            circleProgressHeight = 119
        }
        
        viewModel.isSplitGoalSelected == true ? (circleProgressHeight = 95) : (circleProgressHeight = 119)
    }
}
