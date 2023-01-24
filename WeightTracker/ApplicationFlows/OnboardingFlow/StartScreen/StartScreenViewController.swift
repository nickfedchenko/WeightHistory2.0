//
//  StartScreenViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import UIKit
import SnapKit

final class StartScreenViewController: UIViewController {
    
    // MARK: - Property list
    private var appNameLabel = UILabel()
    private var screenDescriptionLabel = UILabel()
    private var backgroundImageView = UIImageView()
    private var startButton = ActionButton(type: .system)
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureAppNameLabel()
        configureScreenDescriptionlabel()
        configureStartButton()
        configureBackgroundView()
    }
    
    private func addSubViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(appNameLabel)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(startButton)
    }
    
    private func configureBackgroundView() {
        backgroundImageView.image = R.image.startScreenBackground()
    }
    
    // MARK: - AppName label
    private func configureAppNameLabel() {
        appNameLabel.font = FontService.shared.localFont(size: 70, bold: true)
        appNameLabel.textColor = .white
        appNameLabel.numberOfLines = 0
        appNameLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.alignment = .center
        appNameLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.startScreenAppName().uppercased(),
            attributes: [NSAttributedString.Key.kern: -0.3, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
    
    // MARK: - Screen description
    private func configureScreenDescriptionlabel() {
        screenDescriptionLabel.textColor = .white
        screenDescriptionLabel.font = FontService.shared.localFont(size: 22, bold: false)
        screenDescriptionLabel.numberOfLines = 0
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.startScreenDescription(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - Start button
    private func configureStartButton() {
        startButton.makeMainState()
        startButton.setTitle(R.string.localizable.buttonsLetsStart().uppercased(), for: .normal)
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
    
    @objc private func startButtonPressed() {
        HapticFeedback.medium.vibrate()
        routeToNextVC()
    }
    
    // MARK: - Other Private methods
    private func routeToNextVC() {
        let vc = UserGenderViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Setup constraints
extension StartScreenViewController {
    
    private func setupConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(154)
            make.centerX.equalToSuperview()
        }

        screenDescriptionLabel.snp.makeConstraints { make in
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
