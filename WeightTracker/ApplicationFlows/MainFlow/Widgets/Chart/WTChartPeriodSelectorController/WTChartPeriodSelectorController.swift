//
//  WTChartPeriodSelectorController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import Amplitude
import UIKit

final class WTChartPeriodSelectorController: UIViewController {
    
    // MARK: - Properties
    private var selectedPeriod: WTChartViewModel.WTChartPeriod
    private var currentMode: WTChartViewModel.WTChartMode
    private weak var rootView: UIView?
    var periodSelectedCallback: ((WTChartViewModel.WTChartPeriod) -> Void)?
    
    private lazy var buttons: [WTChartPeriodSelectorButton] = {
        let buttons: [WTChartPeriodSelectorButton] =  WTChartViewModel.WTChartPeriod.allCases
            .enumerated()
            .compactMap { [weak self] index, period in
                guard let self = self else { return nil }
                let button = WTChartPeriodSelectorButton(with: currentMode, period: period)
                button.tag = index
                let attrTitleSelected = NSAttributedString(
                    string: period.buttonTitle,
                    attributes: [
                        .font: R.font.openSansMedium(size: 20) ?? UIFont.systemFont(ofSize: 20),
                        .foregroundColor: UIColor.white
                    ]
                )
                let attrTitleDeselected = NSAttributedString(
                    string: period.buttonTitle,
                    attributes: [
                        .font: R.font.openSansMedium(size: 20) ?? UIFont.systemFont(ofSize: 20),
                        .foregroundColor:  self.currentMode.dominantColor
                    ]
                )
                button.setAttributedTitle(attrTitleSelected, for: .selected)
                button.setAttributedTitle(attrTitleDeselected, for: .normal)
                button.layer.cornerRadius = 8
                button.layer.cornerCurve = .continuous
                button.alpha = 0
                button.addTarget(self, action: #selector(periodSelected(sender:)), for: .touchUpInside)
                return button
            }
        var finalButtonsResult: [WTChartPeriodSelectorButton] = []
        buttons.forEach {
            if $0.period == selectedPeriod {
                finalButtonsResult.insert($0, at: 0)
                $0.isSelected = true
            } else {
                finalButtonsResult.append($0)
                $0.isSelected = false
            }
        }
        return finalButtonsResult
    }()
    
    let buttonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        stackView.spacing = 12
        stackView.backgroundColor = UIColor(hex: "FEF4EC")
        stackView.layer.cornerRadius = 16
        stackView.alpha = 0
        return stackView
    }()
    
    // MARK: - Init
    init(
        with currentlySelectedPeriod: WTChartViewModel.WTChartPeriod,
        rootView: UIView,
        currentMode: WTChartViewModel.WTChartMode
    ) {
        self.selectedPeriod = currentlySelectedPeriod
        self.currentMode = currentMode
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        disappear()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        appear()
    }
    
    // MARK: - Private methods
    private func setupSubViews() {
        view.addSubview(buttonsStack)
        buttons.forEach { buttonsStack.addArrangedSubview($0) }
        guard let rootView = rootView else { return }
        buttonsStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(rootView.frame.origin.y)
            make.leading.equalToSuperview().offset(self.view.bounds.width)
            make.width.equalTo(175)
            make.height.equalTo(100)
        }
    }
    
    @objc private func periodSelected(sender: WTChartPeriodSelectorButton) {
        buttons.enumerated().forEach { index, button in
            sender.isSelected = true
            if index != sender.tag {
                button.isSelected = false
            }
        }
        
        periodSelectedCallback?(sender.period)
        Amplitude.instance().logEvent("time_chosen", withEventProperties: ["withChartPeriod" : sender.period.buttonTitle])
    }
    
    private func appear() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .black.withAlphaComponent(0.25)
        } completion: { [weak self] _ in
            guard
                let self = self
            else { return }
            self.buttonsStack.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(UIScreen.main.bounds.width - 24 - 175)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.buttonsStack.snp.updateConstraints { make in
                    make.height.equalTo(288)
                }
                UIView.animate(withDuration: 0.2) {
                    self.buttons.forEach { $0.alpha = 1 }
                    self.buttonsStack.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func disappear() {
        buttonsStack.spacing = 0
        buttonsStack.directionalLayoutMargins = .zero
        self.buttonsStack.snp.updateConstraints { make in
            make.height.equalTo(75)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
}
