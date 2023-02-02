//
//  MainStageViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import ApphudSDK
import UIKit

final class MainStageViewController: UIViewController {
    
    // MARK: - Property list
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    
    private var chartViewContainer = UIView()
    private var wtChart = WTChartView()
    private let wtChartModeSelector = WTChartModeSelector()
    private let wtChartPeriodSelector = WTChartPeriodSelectorView()
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    private var widgetsViewContainer = UIView()
    private var bmiWidgetView = BMIWidgetView()
    private var bmiView = BMIOpenView()
    private var compactChestWidgetView = WTCompactWidgetView()
    private var compactWaistWidgetView = WTCompactWidgetView()
    private var compactHipWidgetView = WTCompactWidgetView()
    private var fastAddWeightWidgetView = FastAddWeightWidgetView()
    private var currentWeightWidgetView = CurrentWeightWidgetView()
    private var goalsWidgetView = GoalsWidgetView()
    private var avatarImageView = UIImageView()
    
    private var viewModel = MainStageViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureWidgets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isAppWasLaunched {
            self.updateWidgetsAfterSettings()
            self.setAvatarImage()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureChartViewLaunch()
        let facade: DataProviderServiceProtocol = DataProviderService.shared
        facade.fetchWeightInfoConditionally { samples in
            return
        }
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        viewModel.isDeviceOld == true ? addSubViewsWithScrollView() : addSubViews()
        configureView()
        configureAvatarImageView()
        setupConstraints()
    }
    
    private func addSubViews() {
        view.addSubview(chartViewContainer)
        view.addSubview(widgetsViewContainer)
        view.addSubview(avatarImageView)
        chartViewContainer.addSubview(wtChart)
        chartViewContainer.addSubview(wtChartModeSelector)
        chartViewContainer.addSubview(wtChartPeriodSelector)
        widgetsViewContainer.addSubview(bmiWidgetView)
        widgetsViewContainer.addSubview(compactChestWidgetView)
        widgetsViewContainer.addSubview(compactWaistWidgetView)
        widgetsViewContainer.addSubview(compactHipWidgetView)
        widgetsViewContainer.addSubview(fastAddWeightWidgetView)
        widgetsViewContainer.addSubview(currentWeightWidgetView)
        widgetsViewContainer.addSubview(goalsWidgetView)
    }
    
    private func addSubViewsWithScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(chartViewContainer)
        contentView.addSubview(widgetsViewContainer)
        contentView.addSubview(avatarImageView)
        chartViewContainer.addSubview(wtChart)
        chartViewContainer.addSubview(wtChartModeSelector)
        chartViewContainer.addSubview(wtChartPeriodSelector)
        widgetsViewContainer.addSubview(bmiWidgetView)
        widgetsViewContainer.addSubview(compactChestWidgetView)
        widgetsViewContainer.addSubview(compactWaistWidgetView)
        widgetsViewContainer.addSubview(compactHipWidgetView)
        widgetsViewContainer.addSubview(fastAddWeightWidgetView)
        widgetsViewContainer.addSubview(currentWeightWidgetView)
        widgetsViewContainer.addSubview(goalsWidgetView)
    }
    
    private func configureView() {
        view.backgroundColor = .mainBackground
        navigationController?.isNavigationBarHidden = true
    }
    
    private func updateWidgetsAfterSettings() {
        updateGoalsWidget()
        bmiWidgetView.configure()
        currentWeightWidgetView.updateWidget()
        configureCompactChestWidget()
    }
    
    // MARK: - WIDGETS CONFIGURATION
    private func configureWidgets() {
        configureChartView()
        configureGoalsWidget()
        configureBmiWidget()
        configureCurrentWeightWidget()
        configureCompactChestWidget()
        configureCompactWaistWidget()
        configureCompactHipWidget()
        configureFastAddWeightWidget()
    }
    
    // MARK: - AVATAR (user settings)
    private func configureAvatarImageView() {
        setAvatarImage()
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.layer.cornerCurve = .continuous
        avatarImageView.layer.shadowColor = UIColor.avatarBorderColor.cgColor
        avatarImageView.layer.shadowOffset = CGSize(width: 0, height: 12)
        avatarImageView.layer.shadowRadius = 31
        avatarImageView.layer.shadowOpacity = 0.20
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.borderColor = UIColor.avatarBorderColor.cgColor
        avatarImageView.isUserInteractionEnabled = true
        configureAvatarTapGesture()
    }
    
    private func setAvatarImage() {
        viewModel.isUserMale() == true ? (avatarImageView.image = R.image.avatarMan()) : (avatarImageView.image = R.image.avatarWomen())
    }
    
    private func configureAvatarTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped))
        tapGesture.cancelsTouchesInView = false
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onAvatarTapped() {
        HapticFeedback.medium.vibrate()
        let vc = SettingsViewController()
        viewModel.isAppWasLaunched = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - CHART
    private func configureChartView() {
        setupModeSelector()
        wtChartPeriodSelector.isUserInteractionEnabled = true
        setupPeriodSelectorActions()
        generator.prepare()
        addSwipeGestureRecognizer()
    }
    
    private func configureChartViewLaunch() {
        let currentDate = Date()
        let wtChartViewModel = WTChartViewModel(mode: viewModel.chartCurrentMode, period: viewModel.chartCurrentPeriod)
        wtChartViewModel.currentDate = currentDate
        viewModel.getDataForChart(for: viewModel.chartCurrentMode.measurementType, period: viewModel.chartCurrentPeriod.days) { [weak self] data in
            wtChartViewModel.rawData = data
            self?.wtChart.viewModel = wtChartViewModel
        }
    }
    
    private func setupPeriodSelectorActions() {
        wtChartPeriodSelector.periodTappeddAction = { [weak self] in
            guard let self = self else { return }
            self.showPeriodSelectorController()
        }
    }
    
    private func showPeriodSelectorController() {
        generator.impactOccurred(intensity: 1)
        let periodSelectorVC = WTChartPeriodSelectorController(
            with: wtChart.viewModel.period, rootView: wtChartPeriodSelector, currentMode: wtChart.viewModel.mode)
        addChild(periodSelectorVC)
        view.addSubview(periodSelectorVC.view)
        periodSelectorVC.periodSelectedCallback = { [weak self] period in
            guard let self = self else { return }
            periodSelectorVC.willMove(toParent: nil)
            periodSelectorVC.removeFromParent()
            self.wtChartPeriodSelector.label.setNewTitle(text: period.buttonTitle)
            self.viewModel.chartCurrentPeriod = period
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                periodSelectorVC.view.removeFromSuperview()
                self.periodSelected(period: period)
            }
        }
        periodSelectorVC.didMove(toParent: self)
    }
    
    private func setupModeSelector() {
        wtChartModeSelector.modeEmitter = { [weak self] mode, direction in
            guard let self = self else { return }
            let currentDate = Date()
            self.wtChart.viewModel.currentDate = currentDate
            self.viewModel.getDataForChart(for: mode.measurementType, period: self.wtChart.viewModel.period.days) { [weak self] samples in
                self?.wtChart.setNewData(data: samples, for: mode, direction: direction)
            }
            self.wtChartPeriodSelector.updateColor(for: mode)
            self.viewModel.chartCurrentMode = mode
        }
    }
    
    private func periodSelected(period: WTChartViewModel.WTChartPeriod) {
        wtChart.viewModel.period = period
        wtChart.viewModel.setNeedUpdate = true
        viewModel.getDataForChart(for: wtChart.viewModel.mode.measurementType, period: period.days) { [weak self] samples in
            guard let self = self else { return }
            self.wtChart.setNewData(data: samples, for: self.wtChart.viewModel.mode, direction: .fromLeft)
        }
    }
    
    private func updateChartViewData() {
        viewModel.getDataForChart(for: wtChart.viewModel.mode.measurementType, period: wtChart.viewModel.period.days) { [weak self] samples in
            guard let self = self else { return }
            self.wtChart.setNewData(data: samples, for: self.wtChart.viewModel.mode, direction: .fromLeft)
        }
    }
    
    private func addSwipeGestureRecognizer() {
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(chartViewDidSwipe(_:)))
        swipeGestureRecognizerLeft.direction = .left
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(chartViewDidSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        wtChart.addGestureRecognizer(swipeGestureRecognizerLeft)
        wtChart.addGestureRecognizer(swipeGestureRecognizerRight)
    }
    
    @objc private func chartViewDidSwipe(_ sender: UISwipeGestureRecognizer) {
        HapticFeedback.selection.vibrate()
        switch sender.direction {
        case .left:
            wtChartModeSelector.graphSlide(by: .fromRight)
        case .right:
            wtChartModeSelector.graphSlide(by: .fromLeft)
        default:
            break
        }
    }
    
    // MARK: - GOALS WIDGET
    private func configureGoalsWidget() {
        goalsWidgetView.configure()
        configureGoalsWidgetViewTapGesture()
    }
    
    private func configureGoalsWidgetViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onGoalsWidgetTapped))
        tapGesture.cancelsTouchesInView = false
        if goalsWidgetView.widgetType == .maintaineWeight {
            return
        } else {
            goalsWidgetView.addGestureRecognizer(tapGesture)
        }
    }
    
    private func updateGoalsWidget() {
        goalsWidgetView.removeFromSuperview()
        goalsWidgetView = GoalsWidgetView()
        widgetsViewContainer.addSubview(goalsWidgetView)
        setupConstraints()
        configureGoalsWidget()
    }
    
    @objc private func onGoalsWidgetTapped() {
        HapticFeedback.medium.vibrate()
        guard !self.showPaywallConditionally() else { return }
        let vc = GoalsViewController()
        vc.widgetCloseCallback = { [weak self] in
            guard let self = self else { return }
            self.updateGoalsWidget()
        }
        self.present(vc, animated: true)
    }
    
    // MARK: - BMI WIDGET
    private func configureBmiWidget() {
        bmiWidgetView.configure()
        configureBmiWidgetCallback()
        configureBmiViewCallback()
    }
    
    private func configureBmiWidgetCallback() {
        bmiWidgetView.onWidgetPressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.bmiAmplitudeLogEvent()
            guard !self.showPaywallConditionally() else { return }
            HapticFeedback.medium.vibrate()
            self.bmiView = BMIOpenView()
            self.bmiView.readyHandler = { [weak self] in
                guard let self = self else {
                    return
                }
                self.view.addSubview(self.bmiView)
                self.bmiView.mainViewContainer.popIn()
                self.bmiView.setBmiArrowStartPosition()
                self.bmiView.animateBMI()
            }
            self.configureBmiViewCallback()
            self.bmiView.setupInitially()
        }
    }
    
    private func configureBmiViewCallback() {
        bmiView.onRemoveFromSuperView = { [weak self] in
            HapticFeedback.selection.vibrate()
            guard let self = self else { return }
            self.bmiView.mainViewContainer.popOut { _ in
                self.bmiView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - CURRENT WEIGHT WIDGET
    private func configureCurrentWeightWidget() {
        currentWeightWidgetView.configure()
        configureCurrentWeightWidgetViewTapGesture()
    }
    
    private func configureCurrentWeightWidgetViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCurrentWeightWidgetTapped))
        tapGesture.cancelsTouchesInView = false
        currentWeightWidgetView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onCurrentWeightWidgetTapped() {
        HapticFeedback.medium.vibrate()
        viewModel.currentWeightWidgetAmplitudeLogEvent()
        guard !self.showPaywallConditionally() else { return }
        let vc = BodyHistoryViewController()
        vc.viewType = .weight
        
        vc.closeCallback = { [weak self] in
            guard let self = self else { return }
            self.currentWeightWidgetView.updateWidget()
            self.updateChartViewData()
        }
        
        vc.addMeasurementCallback = { [weak self] in
            guard let self = self else { return }
            let measurVC = MeasurementsViewController(type: .weight)
            measurVC.closeCallback = { [weak self] in
                guard let self = self else { return }
                self.currentWeightWidgetView.configure()
                self.bmiWidgetView.configure()
                self.updateGoalsWidget()
                self.updateChartViewData()
                self.configureCurrentWeightWidgetViewTapGesture()
            }
            self.present(measurVC, animated: true)
        }
        self.present(vc, animated: true)
    }
    
    // MARK: - COMPACT CHEST WIDGET
    private func configureCompactChestWidget() {
        compactChestWidgetView.widgetType = .chest
        compactChestWidgetView.updateLastMeasurement(with: viewModel.getLastMeasurement(for: .chest))
        configureCompactChestWidgetCallback()
    }
    
    private func configureCompactChestWidgetCallback() {
        compactChestWidgetView.onWidgetPressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.compactChestWidgetAmplitudeLogEvent()
            guard !self.showPaywallConditionally() else { return }
            let vc = BodyHistoryViewController()
            vc.viewType = .chest
            
            vc.closeCallback = { [weak self] in
                guard let self = self else { return }
                self.compactChestWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .chest))
                self.updateChartViewData()
            }
            
            vc.addMeasurementCallback = { [weak self] in
                guard let self = self else { return }
                let measurVC = MeasurementsViewController(type: .chest)
                measurVC.viewType = .chest
                measurVC.closeCallback = { [weak self] in
                    guard let self = self else { return }
                    self.updateChartViewData()
                    self.compactChestWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .chest))
                }
                self.present(measurVC, animated: true)
            }
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - COMPACT WAIST WIDGET
    private func configureCompactWaistWidget() {
        compactWaistWidgetView.widgetType = .waist
        compactWaistWidgetView.updateLastMeasurement(with: viewModel.getLastMeasurement(for: .waist))
        configureCompactWaistWidgetCallback()
    }
    
    private func configureCompactWaistWidgetCallback() {
        compactWaistWidgetView.onWidgetPressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.compactWaistWidgetAmplitudeLogEvent()
            guard !self.showPaywallConditionally() else { return }
            let vc = BodyHistoryViewController()
            vc.viewType = .waist
            
            vc.closeCallback = { [weak self] in
                guard let self = self else { return }
                self.compactWaistWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .waist))
                self.updateChartViewData()
            }
            
            vc.addMeasurementCallback = { [weak self] in
                guard let self = self else { return }
                let measurVC = MeasurementsViewController(type: .waist)
                measurVC.viewType = .waist
                measurVC.closeCallback = { [weak self] in
                    guard let self = self else { return }
                    self.updateChartViewData()
                    self.compactWaistWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .waist))
                }
                self.present(measurVC, animated: true)
            }
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - COMPACT HIP WIDGET
    private func configureCompactHipWidget() {
        compactHipWidgetView.widgetType = .hip
        compactHipWidgetView.updateLastMeasurement(with: viewModel.getLastMeasurement(for: .hip))
        configureCompactHipWidgetCallback()
    }
    
    private func configureCompactHipWidgetCallback() {
        compactHipWidgetView.onWidgetPressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.compactHipWidgetAmplitudeLogEvent()
            guard !self.showPaywallConditionally() else { return }
            let vc = BodyHistoryViewController()
            vc.viewType = .hip
            
            vc.closeCallback = { [weak self] in
                guard let self = self else { return }
                self.compactHipWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .hip))
                self.updateChartViewData()
            }
            
            vc.addMeasurementCallback = { [weak self] in
                guard let self = self else { return }
                let measurVC = MeasurementsViewController(type: .hip)
                measurVC.viewType = .hip
                measurVC.closeCallback = { [weak self] in
                    guard let self = self else { return }
                    self.updateChartViewData()
                    self.compactHipWidgetView.updateLastMeasurement(with: self.viewModel.getLastMeasurement(for: .hip))
                }
                self.present(measurVC, animated: true)
            }
            
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - FAST ADD WEIGHT WIDGET
    private func configureFastAddWeightWidget() {
        fastAddWeightWidgetView.configure()
        configureFastAddWeightWidgetCallback()
    }
    
    private func configureFastAddWeightWidgetCallback() {
        fastAddWeightWidgetView.onWidgetPressed = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fastAddWidgetAmplitudeLogEvent()
            guard !self.showPaywallConditionally() else { return }
            let vc = MeasurementsViewController(type: .weight)
            vc.viewType = .weight

            vc.closeCallback = { [weak self] in
                guard let self = self else { return }
                self.currentWeightWidgetView.updateWidget()
                self.bmiWidgetView.configure()
                self.updateGoalsWidget()
                self.updateChartViewData()
            }
            self.present(vc, animated: true)
        }
    }
}

// MARK: - Setup constraints
extension MainStageViewController {
    
    private func setupConstraints() {
        
        if viewModel.isDeviceOld {
            scrollView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide)
            }
            
            contentView.snp.makeConstraints { make in
                make.width.equalTo(view.frame.width)
                make.top.equalToSuperview().inset(5)
                make.bottom.equalToSuperview()
            }
        }
        
        if viewModel.isDeviceOld {
            chartViewContainer.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().inset(2)
                make.height.equalTo(283)
                make.bottom.equalTo(widgetsViewContainer.snp.top).inset(-12)
            }
        } else {
            chartViewContainer.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).inset(2)
                make.bottom.equalTo(widgetsViewContainer.snp.top).inset(-12)
            }
        }
        
        widgetsViewContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(viewModel.sideIndent)
            make.bottom.equalToSuperview().inset(48)
        }
        
        // Avatar
        avatarImageView.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalTo(56)
            make.top.equalTo(wtChart.snp.top)
            make.leading.equalToSuperview().inset(24)
        }
        
        // Chart
        wtChart.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview()
        }
        
        wtChartModeSelector.snp.makeConstraints { make in
            make.width.equalTo(154)
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(wtChart.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        wtChartPeriodSelector.snp.makeConstraints { make in
            make.trailing.equalTo(wtChart)
            make.bottom.equalTo(wtChart.snp.bottom).offset(32)
            make.width.equalTo(80)
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }
        
        // BMI
        bmiWidgetView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(viewModel.mediumWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
        }
        
        // Chest
        compactChestWidgetView.snp.makeConstraints { make in
            make.top.equalTo(bmiWidgetView.snp.bottom).inset(-16)
            make.height.equalTo(viewModel.compactWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
            make.trailing.equalToSuperview()
        }
        
        // Waist
        compactWaistWidgetView.snp.makeConstraints { make in
            make.top.equalTo(compactChestWidgetView.snp.bottom).inset(-16)
            make.height.equalTo(viewModel.compactWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
            make.trailing.equalToSuperview()
        }
        
        // Hip
        compactHipWidgetView.snp.makeConstraints { make in
            make.top.equalTo(compactWaistWidgetView.snp.bottom).inset(-16)
            make.height.equalTo(viewModel.compactWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
            make.trailing.equalToSuperview()
        }
        
        // Fast weight
        fastAddWeightWidgetView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(viewModel.smallWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
        }
        
        // Weight
        currentWeightWidgetView.snp.makeConstraints { make in
            make.height.equalTo(viewModel.mediumWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
            make.leading.equalToSuperview()
            make.bottom.equalTo(fastAddWeightWidgetView.snp.top).inset(-16)
        }
        
        // Milestone
        goalsWidgetView.snp.makeConstraints { make in
            make.height.equalTo(viewModel.largeWidgetHeight)
            make.width.equalTo(viewModel.widgetWidth)
            make.leading.top.equalToSuperview()
            make.bottom.equalTo(currentWeightWidgetView.snp.top).inset(-16)
        }
    }
}

// MARK: - Paywall
extension MainStageViewController {
    func showPaywallConditionally() -> Bool {
        guard !Apphud.hasActiveSubscription() else { return false }
        let paywall = PaywallViewController()
        paywall.modalPresentationStyle = .fullScreen
        present(paywall, animated: true)
        return true
    }
}
