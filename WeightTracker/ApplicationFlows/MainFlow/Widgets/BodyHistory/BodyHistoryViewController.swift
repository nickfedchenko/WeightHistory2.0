//
//  BodyHistoryViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 31.01.2023.
//

import UIKit

final class BodyHistoryViewController: UIViewController {

    // MARK: - Property list
    private var titleLabel = UILabel()
    private var closeButton = UIButton(type: .custom)
    private var periodSelector = BodyHistoryPeriodSelector()
    private var measurementTableView = UITableView()
    private var addMeasurementButton = ActionButton(type: .custom)
    private var averageLabel = UILabel()
    private var mainViewContainer = UIView()
    private var blackoutView = UIView()
    
    private var isBool = false
    private var viewModel = BodyHistoryViewModel()
    
    var viewType: MeasurementTypes = .weight
    var closeCallback: (() -> Void)?
    var addMeasurementCallback: (() -> Void)?

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadHandler = { [weak self] in
            self?.measurementTableView.reloadData()
        }
        viewModel.getMeasurements(for: viewType)
        viewModel.fetchWeightMeasurementsFromHealthKit()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeCallback?()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubviews()
        configureView()
        configureWidgetTitleLabel()
        configureTableView()
        configureCloseWidgetButton()
        configureAddButton()
        configurePeriodSelector()
        dissmisVcWhenTapBlackOutView()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(mainViewContainer)
        view.addSubview(blackoutView)
        mainViewContainer.addSubview(titleLabel)
        mainViewContainer.addSubview(closeButton)
        mainViewContainer.addSubview(periodSelector)
        mainViewContainer.addSubview(measurementTableView)
        mainViewContainer.addSubview(addMeasurementButton)
        mainViewContainer.addSubview(averageLabel)
    }
    
    private func configureView() {
        view.backgroundColor = .clear
        mainViewContainer.layer.cornerRadius = 16
        mainViewContainer.layer.cornerCurve = .continuous
        mainViewContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        mainViewContainer.backgroundColor = .white
    }
    
    // MARK: - TABLE VIEW CONFIGURATION
    private func configureTableView() {
        registerCell()
        measurementTableView.delegate = self
        measurementTableView.dataSource = self
        measurementTableView.backgroundColor = .clear
        measurementTableView.separatorStyle = .none
        measurementTableView.showsVerticalScrollIndicator = false
    }
    
    private func registerCell() {
        measurementTableView.register(BodyHistoryTableViewCell.self, forCellReuseIdentifier: BodyHistoryTableViewCell.identifier)
        measurementTableView.register(EmptyBodyHistoryTableViewCell.self, forCellReuseIdentifier: EmptyBodyHistoryTableViewCell.identifier)
    }
    
    // MARK: - LABELS
    private func configureAverageLabel(for button: UIButton) {
        averageLabel.textColor = viewType.color
        averageLabel.font = R.font.openSansMedium(size: 17)
        
        if button.titleLabel?.text == R.string.localizable.periodsDaily() {
            updateTitle(withConstraint: Int(view.frame.width / 2 - titleLabel.intrinsicContentSize.width / 2), averageLabelIsHidden: true)
        }
        
        if button.titleLabel?.text == R.string.localizable.periodsWeekly() {
            averageLabel.text = R.string.localizable.periodsAverageWeeklyAverage()
            updateTitle(withConstraint: 24, averageLabelIsHidden: false)
        }
        
        if button.titleLabel?.text == R.string.localizable.periodsMonthly() {
            averageLabel.text = R.string.localizable.periodsAverageMonthlyAverage()
            updateTitle(withConstraint: 24, averageLabelIsHidden: false)
        }
    }
    
    private func configureWidgetTitleLabel() {
        titleLabel.text = viewType.title
        titleLabel.textColor = viewType.color
        titleLabel.font = R.font.promptSemiBold(size: 20)
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseWidgetButton() {
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        closeButton.tintColor = viewType.color
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func dismissVC() {
        HapticFeedback.selection.vibrate()
        dismiss(animated: true)
    }
    
    // MARK: - ADD BUTTON
    private func configureAddButton() {
        addMeasurementButton.makeBodyWidgetState(for: viewType)
        addMeasurementButton.setImage(R.image.plus(), for: .normal)
        addMeasurementButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    @objc private func addButtonPressed() {
        HapticFeedback.medium.vibrate()
        dismiss(animated: true) {
            self.addMeasurementCallback?()
        }
    }
    
    //MARK: - Private methods
    private func updateTitle(withConstraint constraint: Int, averageLabelIsHidden: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.averageLabel.isHidden = averageLabelIsHidden
            self.titleLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(constraint)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func dissmisVcWhenTapBlackOutView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissVC))
        tapGesture.cancelsTouchesInView = false
        self.blackoutView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - PERIOD SELECTOR
    private func configurePeriodSelector() {
        periodSelector.selectorType = viewType
        periodSelector.configure()
        configurePeriodSelectorCallbacks()
    }
    
    private func configurePeriodSelectorCallbacks() {
        periodSelector.buttonCallback = { [weak self] butt in
            guard let self = self else { return }
            if self.periodSelector.isSelectorChanged == true {
                self.configureAverageLabel(for: butt)
            }
            
            if butt.titleLabel?.text == R.string.localizable.periodsDaily() {
                self.viewModel.period = .daily
                self.isBool = true
                self.measurementTableView.reloadData()
            }
            
            if butt.titleLabel?.text == R.string.localizable.periodsWeekly() {
                self.viewModel.period = .weekly
                
                switch self.viewType {
                case .chest:   self.viewModel.getChestWeeklyAverageMeasurements()
                case .waist:   self.viewModel.getWaistWeeklyAverageMeasurements()
                case .hip:     self.viewModel.getHipWeeklyAverageMeasurements()
                case .weight:  self.viewModel.getWeightWeeklyAverageMeasurements()
                case .bmi:     return
                }
                
                self.isBool = true
                self.measurementTableView.reloadData()
            }
            
            if butt.titleLabel?.text == R.string.localizable.periodsMonthly() {
                self.viewModel.period = .monthly
                
                switch self.viewType {
                case .chest:   self.viewModel.getChestMonthlyAverageMeasurements()
                case .waist:   self.viewModel.getWaistMonthlyAverageMeasurements()
                case .hip:     self.viewModel.getHipMonthlyAverageMeasurements()
                case .weight:  self.viewModel.getWeightMonthlyAverageMeasurements()
                case .bmi:     return
                }
                
                self.isBool = true
                self.measurementTableView.reloadData()
            }
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension BodyHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isArrayEmpty(for: viewType) {
            if isBool {
                return 10
            } else {
                isBool.toggle()
                return 0
            }
        } else {
            if viewModel.period == .daily {
                return viewModel.getDataCount(for: viewType)
            } else {
                return viewModel.averageMeasurements.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure cell without data
        if viewModel.isArrayEmpty(for: viewType) {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: EmptyBodyHistoryTableViewCell.identifier, for: indexPath) as? EmptyBodyHistoryTableViewCell
            emptyCell?.configure(for: viewType, with: indexPath.row)
            return emptyCell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BodyHistoryTableViewCell.identifier, for: indexPath) as? BodyHistoryTableViewCell
            
            // Configure by period
            if viewModel.period == .weekly {
                cell?.configureWithPeriod(
                    for: viewType,
                    measurement: viewModel.averageMeasurements[indexPath.row].averangeDimension,
                    date: viewModel.averageMeasurements[indexPath.row].datePeriod,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit()
                )
                return cell ?? UITableViewCell()
            }
            
            if viewModel.period == .monthly {
                cell?.configureWithPeriod(
                    for: viewType,
                    measurement: viewModel.averageMeasurements[indexPath.row].averangeDimension,
                    date: viewModel.averageMeasurements[indexPath.row].datePeriod,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit()
                )
                return cell ?? UITableViewCell()
            }
            
            // Configure with widget type
            switch viewType {
            case .chest:
                cell?.configure(
                    for: .chest,
                    measurement: viewModel.chestMeasurements[indexPath.row].chest,
                    date: viewModel.chestMeasurements[indexPath.row].date,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit()
                )
                return cell ?? UITableViewCell()
                
            case .waist:
                cell?.configure(
                    for: .waist,
                    measurement: viewModel.waistMeasurements[indexPath.row].waist,
                    date: viewModel.waistMeasurements[indexPath.row].date,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit()
                )
                return cell ?? UITableViewCell()
                
            case .hip:
                cell?.configure(
                    for: .hip,
                    measurement: viewModel.hipMeasurements[indexPath.row].hip,
                    date: viewModel.hipMeasurements[indexPath.row].date,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit()
                )
                return cell ?? UITableViewCell()
                
            case .weight:
                cell?.configure(
                    for: .weight,
                    measurement: viewModel.weightMeasurementsFromHK[indexPath.row].value,
                    date: viewModel.weightMeasurementsFromHK[indexPath.row].date,
                    widthUnit: viewModel.getUserWidthUnit(),
                    lengthUnit: viewModel.getUserLenghtUnit(),
                    isFromHK: viewModel.weightMeasurementsFromHK[indexPath.row].isFromHK
                )
                return cell ?? UITableViewCell()
                
            case .bmi: return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        41
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if viewModel.weightMeasurementsFromHK[indexPath.row].isFromHK {
            return
        }
        if editingStyle == .delete && periodSelector.isDailyPeriod {
            viewModel.deleteMeasurementFromDB(for: viewType, with: indexPath.row)
            viewModel.deleteMeasurementFromVM(for: viewType, indexPath: indexPath.row)
            
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [indexPath], with: .automatic)

                if viewModel.isArrayEmpty(for: viewType) {
                    DispatchQueue.main.async {
                        self.isBool = true
                        tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - Setup constraint
extension BodyHistoryViewController {
    
    private func setupConstraints() {
        
        mainViewContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.height / 3 * 2)
        }
        
        blackoutView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(mainViewContainer.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(view.frame.width / 2 - titleLabel.intrinsicContentSize.width / 2)
            make.height.equalTo(40)
        }
        
        averageLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).inset(-16)
        }
        
        periodSelector.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).inset(-16)
            make.height.equalTo(40)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(18)
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
        
        measurementTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.top.equalTo(periodSelector.snp.bottom).offset(8)
            make.bottom.equalTo(addMeasurementButton.snp.top).inset(-20)
        }
        
        addMeasurementButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
            make.bottom.equalToSuperview().inset(48)
        }
    }
}
