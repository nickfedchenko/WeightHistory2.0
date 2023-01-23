//
//  StartScreenViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import UIKit
import SnapKit

final class StartScreenViewController: UIViewController {
    
    //MARK: - Property list
    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var backgroundImageView = UIImageView()
    private var startButton = CustomButton(type: .system)
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - ConfigureUI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureTitleLabel()
        configureDescriptionlabel()
        configureStartButton()
        configureBackgroundView()
    }
    
    private func addSubViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(startButton)
    }
    
    private func configureTitleLabel() {
        titleLabel.font = R.font.promptBold(size: 70)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.76
        paragraphStyle.alignment = .center
        titleLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.startScreenAppName().uppercased(),
            attributes: [NSAttributedString.Key.kern: -0.3, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
    
    private func configureDescriptionlabel() {
        descriptionLabel.textColor = .white
        descriptionLabel.font = R.font.promptSemiBold(size: 22)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textAlignment = .center
        descriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.startScreenDescription(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    private func configureStartButton() {
        startButton.makeMainState()
        startButton.setTitle(R.string.localizable.buttonsLetsStart().uppercased(), for: .normal)
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
    
    private func configureBackgroundView() {
        backgroundImageView.image = R.image.splashBackground()
    }
    
    //MARK: - Other Private methods
    private func routeToNextVc() {
        let vc = GenderViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Buttons actions
    @objc private func startButtonPressed() {
        HapticFeedback.medium.vibrate()
        routeToNextVc()
    }
}

//MARK: - Setup constraints
extension StartScreenViewController {
    
    private func setupConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(154)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.bottom.equalTo(startButton.snp.top).offset(-45)
        }

        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(90)
            make.height.equalTo(72)
        }
    }
}
