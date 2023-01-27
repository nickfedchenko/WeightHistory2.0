//
//  WTChartView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class WTChartView: UIView {
    
    // MARK: - Properties
    private var innerContainerVerticalInset: CGFloat = 16.5
    private var innerContainerHorizontalInset: CGFloat = 16.5
    private var dateLables: [UILabel] = []
    private var valueLabels: [UILabel] = []
    
    private let innerContainer: WTChartInnerContainer = {
        let view = WTChartInnerContainer()
        return view
    }()
    
    private let mountImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.mount()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    var viewModel: WTChartViewModel! {
        didSet {
            prepare()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        placeInnerContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Publick methods
    func setNewData(data: [WTGraphRawDataModel], for mode: WTChartViewModel.WTChartMode, direction: WTChartModeSelector.SlideDirection) {
        let transition = CATransition()
        transition.type = .moveIn
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transition.subtype = direction == .fromLeft ? .fromLeft : .fromRight
        innerContainer.layer.add(transition, forKey: nil)
        viewModel.rawData = data
        viewModel.mode = mode
        viewModel.setNeedUpdate = true
        
        if viewModel.rawData.count > 1 && mountImageView.isDescendant(of: self) {
            mountImageView.removeFromSuperview()
        } else if viewModel.rawData.count < 2 {
            placeMountImageView()
        }
    }
    
    func prepare() {
     precondition(viewModel != nil, "Set viewModel first")
        guard let viewModel = viewModel else { return }
        viewModel.innerContainerSizeProvider = { [weak self] in
            guard let self = self else { return (.zero, .zero, .zero) }
            return (self.innerContainer.frame.size, self.innerContainerVerticalInset, self.innerContainerHorizontalInset)
        }
        
        viewModel.updateHandler = innerContainer.setData(dataSet:)
        viewModel.outerContainerHandler = makeLabels(with:)
        viewModel.setNeedUpdate = true
        
        if viewModel.rawData.count < 2 {
            placeMountImageView()
        }
    }
    
    
    
    func makeLabels(with data: WTChartViewModel.WTChartDrawInstructions) {
        if !dateLables.isEmpty {
            for (index, date) in data.outerContainerData.timeValues.enumerated() {
                dateLables[index].text = date
            }
        } else {
            for (index, date) in data.outerContainerData.timeValues.enumerated() {
                let label = UILabel()
                label.font = R.font.openSansMedium(size: 12)
                label.textColor = UIColor(hex: "A78A74")
                label.text = date
                label.textAlignment = .center
                label.alpha = 0
                dateLables.append(label)
                addSubview(label)
                label.snp.makeConstraints { make in
                    make.centerX.equalTo(data.innerContainerDrawingData.vAxisXcoordinates[index])
                    make.top.equalTo(innerContainer.snp.bottom)
                }
                
                UIView.animate(withDuration: 0.3, delay: 0.3 + 0.02 * Double(index)) {
                    label.alpha = 1
                }
            }
        }
        
        valueLabels.forEach { $0.removeFromSuperview() }
        valueLabels.removeAll()
        
        var shouldShowFloat = false
        if
            let min = data.outerContainerData.values.min(),
            let max = data.outerContainerData.values.max() {
            shouldShowFloat = (max - min).truncatingRemainder(dividingBy: (viewModel.mode == .weight ? 5 : 3) ) == 0 ? false : true
        }
        for (index, value) in data.outerContainerData.values.enumerated() {
            let label = UILabel()
            label.font = R.font.openSansRegular(size: 12)
            label.textColor = UIColor(hex: "A78A74")
            label.text = shouldShowFloat ? String(format: "%.1f", value) : String(format: "%.0f", value)
            label.alpha = 0
            addSubview(label)
            valueLabels.append(label)
            label.snp.makeConstraints { make in
                make.centerY.equalTo(data.innerContainerDrawingData.hAxisYcoordinates[index])
                make.trailing.equalToSuperview()
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.3 + 0.02 * Double(index)) {
                label.alpha = 1
            }
        }
    }
    
    // MARK: - Private methods
    private func placeInnerContainer() {
        addSubview(innerContainer)
        innerContainer.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(18)
        }
    }
    
    private func placeMountImageView() {
        addSubview(mountImageView)
        mountImageView.alpha = 0
        mountImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        UIView.animate(withDuration: 0.6, delay: 0) {
            self.mountImageView.alpha = 1
        }
    }
}
