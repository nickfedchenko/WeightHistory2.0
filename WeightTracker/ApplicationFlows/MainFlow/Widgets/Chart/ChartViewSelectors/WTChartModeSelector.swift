//
//  WTChartModeSelector.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartModeSelector: UIView {
    
    enum SlideDirection {
        case fromLeft, fromRight
    }
    
    // MARK: - Properies
    var modeEmitter: ((WTChartViewModel.WTChartMode, SlideDirection) -> Void)?
    
    var modes =  WTChartViewModel.WTChartMode.allCases
    var currentMode: WTChartViewModel.WTChartMode = .weight
    
    private lazy var thumbs: [ModeSelectorThumbView] = {
        var thumbs: [ModeSelectorThumbView] = []
        WTChartViewModel.WTChartMode.allCases.enumerated().forEach { index, mode in
            let view = ModeSelectorThumbView()
            view.tag = index
            view.backgroundColor = mode.dominantColor
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modeControlSelected(sender:))))
            thumbs.append(view)
        }
        return thumbs
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitially()
        setupConstraints(by: .fromRight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    @objc private func modeControlSelected(sender: UITapGestureRecognizer) {
        guard let label = sender.view else { return }
              let tag = label.tag
        if let currentIndex = modes.firstIndex(of: currentMode) {
            let direction: SlideDirection = currentIndex < tag ? .fromRight : .fromLeft
            currentMode = modes[tag]
            setupConstraints(by: direction)
            modeEmitter?(currentMode, direction)
        }
    }
    
    private func setupInitially() {
        thumbs.forEach {
            addSubview($0)
        }
    }
    
    // MARK: - Publick methods
    func graphSlide(by direction: SlideDirection) {
        if direction == .fromLeft {
            if var currentIndex = modes.firstIndex(of: currentMode) {
                if currentIndex == 0 {
                    currentMode = modes.last ?? .hip
                    currentIndex = 4
                } else {
                    currentIndex -= 1
                    currentMode = modes[currentIndex]
                }
            }
        } else {
            if var currentIndex = modes.firstIndex(of: currentMode) {
                if currentIndex == 4 {
                    currentMode = modes.first ?? .weight
                    currentIndex = 0
                } else {
                    currentIndex += 1
                    currentMode = modes[currentIndex]
                }
            }
        }
        setupConstraints(by: direction)
        modeEmitter?(currentMode, direction)
    }
    
    // MARK: - Constraints
    private func setupConstraints(by direction: SlideDirection) {
        guard let targetIndex = modes.firstIndex(of: currentMode) else { return }
        
        thumbs.forEach { $0.snp.removeConstraints() }
        for (index, label) in thumbs.enumerated() {
            if index == targetIndex {
                label.snp.makeConstraints { make in
                    make.width.equalTo(54)
                    make.top.bottom.equalToSuperview()
                }
            } else {
                label.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.width.height.equalTo(12)
                }
            }
            
            if index == 0 {
                label.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                }
            } else if index == thumbs.count - 1 {
                label.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                }
            } else {
                label.snp.makeConstraints { make in
                    make.leading.equalTo(thumbs[index - 1].snp.trailing).offset(12)
                }
            }
        }
        UIView.animate(withDuration: 0.3) {
            
            self.thumbs.enumerated().forEach { index, label in
                if index == targetIndex {
                    label.layer.cornerRadius = 10
                } else {
                    label.layer.cornerRadius = 6
                }
            }
            self.layoutIfNeeded()
            self.thumbs.enumerated().forEach { index, thumb in
                if index == targetIndex {
                    if thumb.label.text != self.currentMode.rawValue.localized {
                        let transition = CATransition()
                        transition.type = .moveIn
                        transition.duration = 0.3
                        transition.subtype = direction == .fromRight ? .fromRight : .fromLeft
                        thumb.label.layer.add(transition, forKey: "text")
                        thumb.label.text = self.currentMode.rawValue.localized
                    }
                } else {
                    let transition = CATransition()
                    transition.type = .moveIn
                    transition.duration = 0.3
                    transition.subtype = direction == .fromRight ? .fromRight : .fromLeft
                    thumb.label.layer.add(transition, forKey: "text")
                    thumb.label.text = ""
                }
            }
        }
    }
}
