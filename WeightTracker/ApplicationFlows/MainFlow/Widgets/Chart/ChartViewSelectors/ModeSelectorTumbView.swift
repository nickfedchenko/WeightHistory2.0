//
//  ModeSelectorTumbView.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

final class ModeSelectorThumbView: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = R.font.openSansMedium(size: 13)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Publick methods
    func setText(_ text: String) {
        label.text = text
    }
    
    // MARK: - Setup view
    private func setupSubviews() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
