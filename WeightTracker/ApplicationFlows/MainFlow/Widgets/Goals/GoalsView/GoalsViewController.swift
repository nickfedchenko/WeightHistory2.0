//
//  GoalsViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

final class GoalsViewController: UIViewController {
    
    // MARK: - Property list
    private var blackoutBackgroundViewContainer = UIView()
    private var mainViewContainer = UIView()
    private var goalsTableView = UITableView()
    private var seporatorView = UIView()
    private var splitSwitch = UISwitch()
    private var goalsSegmentControl = GoalsSegmentView()
    private var goalsLineProgressView = GoalsLineProgressView()
    private var goalsCircleProgressView = GoalsCircleProgressView()
    private var pickGoalsView = PickGoalsNumberView()
    private var closeButton = UIButton(type: .system)
    
    private var widgetTitleLabel = UILabel()
    private var oneMileLabel = UILabel()
    private var splitMyGoalLabel = UILabel()
    private var intoLabel = UILabel()
    private var goalsLabel = UILabel()
    private var completedStepsLabel = UILabel()
    private var startLabel = UILabel()
    private var nowLabel = UILabel()
    private var goalLabel = UILabel()
    private var startIndexLabel = UILabel()
    private var nowIndexLabel = UILabel()
    private var goalIndexLabel = UILabel()
    private var overallLabel = UILabel()
    
    private var viewModel = GoalsViewModel()
    
    var widgetCloseCallback: (() -> Void)?
        
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configure()
        configureUI()
        configureViewTapGesture()
        configureCallbacks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        widgetCloseCallback?()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        setupGoalsTableViewConstraints()
        configureView()
        configureGoalsTableView()
        configureSeporatorView()
        configureLabels()
        configureSplitSwitch()
        configureGoalsSegmentControl()
        configureGoalsLineProgressView()
        configureCircleProgressView()
        configureCloseButton()
    }
    
    private func addSubViews() {
        view.addSubview(blackoutBackgroundViewContainer)
        view.addSubview(mainViewContainer)
        // Labels
        mainViewContainer.addSubview(oneMileLabel)
        mainViewContainer.addSubview(splitMyGoalLabel)
        mainViewContainer.addSubview(intoLabel)
        mainViewContainer.addSubview(goalsLabel)
        mainViewContainer.addSubview(completedStepsLabel)
        mainViewContainer.addSubview(startLabel)
        mainViewContainer.addSubview(nowLabel)
        mainViewContainer.addSubview(goalLabel)
        mainViewContainer.addSubview(widgetTitleLabel)
        mainViewContainer.addSubview(startIndexLabel)
        mainViewContainer.addSubview(nowIndexLabel)
        mainViewContainer.addSubview(goalIndexLabel)
        mainViewContainer.addSubview(overallLabel)
        // Other elements
        mainViewContainer.addSubview(goalsTableView)
        mainViewContainer.addSubview(closeButton)
        mainViewContainer.addSubview(seporatorView)
        mainViewContainer.addSubview(splitSwitch)
        mainViewContainer.addSubview(goalsSegmentControl)
        mainViewContainer.addSubview(goalsLineProgressView)
        mainViewContainer.addSubview(goalsCircleProgressView)
    }
    
    private func configureView() {
        view.backgroundColor = .clear
        mainViewContainer.layer.backgroundColor = UIColor.white.cgColor
        mainViewContainer.layer.cornerRadius = 16
        mainViewContainer.layer.cornerCurve = .continuous
    }
    
    private func configureGoalsTableView() {
        registerCells()
        goalsTableView.dataSource = self
        goalsTableView.delegate = self
        goalsTableView.separatorStyle = .none
        goalsTableView.showsVerticalScrollIndicator = false
        goalsTableView.backgroundColor = .clear
        if viewModel.isDeviceOld {
            goalsTableView.isUserInteractionEnabled = true
        } else {
            goalsTableView.isUserInteractionEnabled = false
        }
    }
    
    private func registerCells() {
        goalsTableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: GoalsTableViewCell.identifier)
    }
    
    private func configureSeporatorView() {
        seporatorView.backgroundColor = .milestoneUnselectedColor
    }
    
    private func configureGoalsSegmentControl() {
        goalsSegmentControl.configure(milestones: viewModel.milestones)
        goalsSegmentControl.isStateOn = viewModel.isSplitGoalSelected
    }
    
    private func configureGoalsLineProgressView() {
        goalsLineProgressView.progress = viewModel.userWeightProgress
        goalsLineProgressView.steps = viewModel.milestones
        goalsLineProgressView.isGoalSplit = viewModel.isSplitGoalSelected
        goalsLineProgressView.currentStepIndex = viewModel.currentStepIndex
    }
    
    private func configureCircleProgressView() {
        goalsCircleProgressView.isGoalSplit = viewModel.isSplitGoalSelected
        goalsCircleProgressView.viewType = .open
        if viewModel.isSplitGoalSelected {
            goalsCircleProgressView.progress = viewModel.milestoneProgress / 100
            goalsCircleProgressView.configure(percent: viewModel.milestoneProgress, weight: viewModel.mileStoneToGo, weightUnit: viewModel.userWeightUnit)
        } else {
            goalsCircleProgressView.progress = viewModel.userWeightProgress
            goalsCircleProgressView.configure(percent: roundHundred(viewModel.userWeightProgress * 100), weight: viewModel.overallToGo, weightUnit: viewModel.userWeightUnit)
        }
    }
    
    // MARK: - Configure labels
    private func configureLabels() {
        configureOneMileLabel()
        confgiureOtherLabels()
        configureCompletedStepsLabel()
        configureStartNowGoalLabels()
        configureWidgetTitleLabel()
        configureOverallLabel()
    }
    
    private func configureOneMileLabel() {
        let text = R.string.localizable.milestoneOneMile() + "\(viewModel.oneMile) " + "\(viewModel.userWeightUnit)"
        var textColor = UIColor.milestoneMainColor
        viewModel.isSplitGoalSelected == true ? (textColor = .milestoneMainColor) : (textColor = .milestoneUnselectedColor)
        configureLabel(label: oneMileLabel, text: text, size: 15, color: textColor)
    }
    
    private func confgiureOtherLabels() {
        if viewModel.isSplitGoalSelected {
            configureLabel(label: splitMyGoalLabel, text: R.string.localizable.milestoneSplitMyGoal(), size: 15, color: .milestoneUsualLabelColor)
            configureLabel(label: intoLabel, text: R.string.localizable.milestoneInto(), size: 15, color: .milestoneUsualLabelColor)
            configureLabel(label: goalsLabel, text: viewModel.milestoneString, size: 15, color: .milestoneUsualLabelColor)
        } else {
            configureLabel(label: splitMyGoalLabel, text: R.string.localizable.milestoneSplitMyGoal(), size: 15, color: .milestoneMainColor)
            configureLabel(label: intoLabel, text: R.string.localizable.milestoneInto(), size: 15, color: .milestoneUnselectedColor)
            configureLabel(label: goalsLabel, text: viewModel.milestoneString, size: 15, color: .milestoneUnselectedColor)
        }
    }
    
    private func configureCompletedStepsLabel() {
        var textColor = UIColor.white
        let text = "\(viewModel.currentStepIndex)" + R.string.localizable.milestoneOf() + "\(viewModel.goalsArray.count - 1)" + " " + R.string.localizable.milestoneMilestones()
        viewModel.isSplitGoalSelected == true ? (textColor = .weightPrimary) : (textColor = .white)
        configureLabel(label: completedStepsLabel, text: text, size: 15, color: textColor)
    }
    
    private func configureStartNowGoalLabels() {
        let startText = "\(viewModel.userStartWeight) \(viewModel.userWeightUnit)"
        let nowtText = "\(viewModel.userCurrentWeight) \(viewModel.userWeightUnit)"
        let goalText = "\(viewModel.userGoalWeight) \(viewModel.userWeightUnit)"
        
        configureLabel(label: startIndexLabel, text: startText, size: 15, color: .milestoneMainColor)
        startLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneStart(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
        
        configureLabel(label: nowIndexLabel, text: nowtText, size: 15, color: .milestoneMainColor)
        nowLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneNow(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
        
        configureLabel(label: goalIndexLabel, text: goalText, size: 15, color: .milestoneMainColor)
        goalLabel.attributedText = NSMutableAttributedString(string: R.string.localizable.milestoneGoal(), attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansSemiBold(size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.milestoneMainColor
        ])
    }
    
    private func configureWidgetTitleLabel() {
        var text = ""
        viewModel.isSplitGoalSelected == true ? (text = R.string.localizable.milestoneMilestone() + "\(viewModel.nextStepIndex)") : (text = R.string.localizable.milestoneMyGoal())
        widgetTitleLabel.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
    }
    
    private func configureOverallLabel() {
        viewModel.isSplitGoalSelected == true ? (overallLabel.isHidden = false) : (overallLabel.isHidden = true)
        overallLabel.numberOfLines = 0
        let text = "\(roundHundred(viewModel.userWeightProgress * 100))% " + R.string.localizable.milestoneCompleteOverall()
        configureLabel(label: overallLabel, text: text, size: 15, color: .milestoneMainColor)
    }
    
    private func configurePickMilestonesView() {
        pickGoalsView = PickGoalsNumberView(frame: .init(origin: .zero, size: .init(width: view.frame.width, height: 291)))
        pickGoalsView.configure()
        mainViewContainer.addSubview(pickGoalsView)
        pickGoalsView.slideUpFromOutside(frame: mainViewContainer.frame, viewHeight: 291)
        configurePickGoalsViewCallbacks()
    }
    
    // MARK: - SPLIT SWITCH
    private func configureSplitSwitch() {
        splitSwitch.isOn = viewModel.isSplitGoalSelected
        splitSwitch.onTintColor = .weightPrimary
        splitSwitch.tintColor = .milestoneUnselectedColor
        splitSwitch.backgroundColor = .milestoneUnselectedColor
        splitSwitch.layer.cornerRadius = 16
        splitSwitch.addTarget(self, action: #selector(splitSwitchValueChanged), for: .valueChanged)
    }
    
    @objc private func splitSwitchValueChanged(mySwitch: UISwitch) {
        viewModel.isSplitGoalSelected.toggle()
        goalsSegmentControl.isStateOn = viewModel.isSplitGoalSelected
        updateAfterSplitSwitchChanged()
    }
    
    //MARK: - Other private methods
    private func configureLabel(label: UILabel, text: String, size: CGFloat, color: UIColor) {
        label.attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: R.font.openSansMedium(size: size) ?? UIFont.systemFont(ofSize: size),
            NSAttributedString.Key.foregroundColor: color.cgColor
        ])
    }
    
    private func updateAfterMilestonesChanged() {
        viewModel.configure()
        updateGoalsLineProgress()
        setupConstraints()
        configureLabels()
        configureGoalsSegmentControl()
        configureGoalsLineProgressView()
        configureCircleProgressView()
        if !viewModel.isDeviceOld {
            updateGoalsTableViewConstraint()
        }
        DispatchQueue.main.async {
            self.goalsTableView.reloadData()
        }
    }
    
    private func updateGoalsLineProgress() {
        goalsLineProgressView.removeFromSuperview()
        goalsLineProgressView = GoalsLineProgressView()
        mainViewContainer.addSubview(goalsLineProgressView)
    }
    
    private func updateAfterSplitSwitchChanged() {
        confgiureOtherLabels()
        configureOneMileLabel()
        configureGoalsLineProgressView()
        configureCompletedStepsLabel()
        configureWidgetTitleLabel()
        configureOverallLabel()
        configureCircleProgressView()
        DispatchQueue.main.async {
            self.goalsTableView.reloadData()
        }
    }
    
    private func updateGoalsTableViewConstraint() {
        goalsTableView.snp.updateConstraints { make in
            make.height.equalTo(viewModel.tableViewHeight)
        }
    }
    
    private func closeWidget(){
        HapticFeedback.selection.vibrate()
        widgetCloseCallback?()
        dismiss(animated: true)
    }
    
    // MARK: - CALLBACKS
    private func configureCallbacks() {
        configureGoalsSegmentCallback()
    }
    
    private func configureGoalsSegmentCallback() {
        goalsSegmentControl.onMilestoneSegmentPressed = { [weak self] in
            HapticFeedback.light.vibrate()
            guard let self = self else { return }
            self.configurePickMilestonesView()
        }
    }
    
    private func configurePickGoalsViewCallbacks() {
        pickGoalsView.onDoneButtonPressed = { [weak self] in
            HapticFeedback.medium.vibrate()
            guard let self = self else { return }
            self.updateAfterMilestonesChanged()
            self.pickGoalsView.slideOutToOutside(frame: self.mainViewContainer.frame, viewHeight: 291)
        }
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .weightPrimary
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        closeWidget()
    }
    
    // MARK: - TAP GESTURE
    private func configureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTapped))
        tapGesture.cancelsTouchesInView = false
        blackoutBackgroundViewContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onBackgroundTapped() {
        closeWidget()
    }
}

// MARK: - TableView DataSource
extension GoalsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.goalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GoalsTableViewCell.identifier, for: indexPath) as? GoalsTableViewCell
                
        if !viewModel.isSplitGoalSelected {
            cell?.cellState = .offState
        } else {
            if indexPath.row == viewModel.nextStepIndex {
                cell?.cellState = .nextStepState
            }
            if indexPath.row > viewModel.nextStepIndex {
                cell?.cellState = .notCompletedState
            }
            if indexPath.row < viewModel.nextStepIndex {
                cell?.cellState = .completedState
            }
        }
        
        cell?.configure(mileText: viewModel.goalsArray[indexPath.row].goalsLabelText, indexText: "\(viewModel.goalsArray[indexPath.row].goalsIndex) " + viewModel.userWeightUnit)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.isDeviceOld && viewModel.nextStepIndex > 5 {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: - Setup constraints
extension GoalsViewController {
    
    private func setupConstraints() {
        
        blackoutBackgroundViewContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        mainViewContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(blackoutBackgroundViewContainer.snp.bottom)
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(28)
            make.top.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().inset(18)
        }
        
        seporatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(55)
            make.bottom.equalTo(oneMileLabel.snp.top).inset(-15)
        }
        
        oneMileLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
                
        splitMyGoalLabel.snp.makeConstraints { make in
            make.trailing.equalTo(splitSwitch.snp.leading).inset(-10)
        }
        
        intoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(splitMyGoalLabel)
        }
        
        goalsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(splitMyGoalLabel)
            make.leading.equalTo(goalsSegmentControl.snp.trailing).inset(-10)
        }
        
        splitSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(splitMyGoalLabel)
            make.trailing.equalTo(intoLabel.snp.leading).inset(-10)
        }
        
        goalsSegmentControl.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(62)
            make.centerY.equalTo(splitMyGoalLabel)
            make.leading.equalTo(intoLabel.snp.trailing).inset(-10)
        }
        
        goalsLineProgressView.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(goalsSegmentControl.snp.top).inset(-18)
        }
        
        widgetTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
            make.height.equalTo(40)
        }
        
        completedStepsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(goalsLineProgressView.snp.top).inset(-8)
        }
        
        goalIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(completedStepsLabel.snp.top).inset(-28)
        }
        
        goalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(goalIndexLabel.snp.top)
        }
        
        nowIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(goalLabel.snp.top).inset(-4)
        }
        
        nowLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(nowIndexLabel.snp.top)
        }
        
        startIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(nowLabel.snp.top).inset(-4)
        }
        
        startLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(45)
            make.bottom.equalTo(startIndexLabel.snp.top)
            make.top.equalTo(widgetTitleLabel.snp.bottom).inset(-10)
        }
        
        overallLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(39)
            make.centerY.equalTo(goalsCircleProgressView.snp.centerY)
            make.width.equalTo(65)
        }
        
        goalsCircleProgressView.snp.makeConstraints { make in
            make.height.equalTo(128)
            make.width.equalTo(128)
            make.centerX.equalToSuperview()
            make.top.equalTo(widgetTitleLabel.snp.bottom).inset(-10)
        }
    }
    
    private func setupGoalsTableViewConstraints() {
        if !viewModel.isDeviceOld {
            goalsTableView.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(45)
                make.trailing.equalToSuperview().inset(51)
                make.bottom.equalTo(seporatorView.snp.top).inset(-8)
                make.top.equalTo(goalsSegmentControl.snp.bottom).inset(-19)
                make.height.equalTo(viewModel.tableViewHeight)
            }
        } else {
            goalsTableView.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(45)
                make.trailing.equalToSuperview().inset(51)
                make.bottom.equalTo(seporatorView.snp.top).inset(-8)
                make.top.equalTo(goalsSegmentControl.snp.bottom).inset(-19)
                make.height.equalTo(168)
            }
        }
    }
}
