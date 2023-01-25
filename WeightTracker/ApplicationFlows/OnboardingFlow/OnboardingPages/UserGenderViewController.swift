//
//  UserGenderViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

final class UserGenderViewController: UIViewController {
    
    // MARK: - Property list
    private var pageControl = CustomPageControl()
    private var genderImageView = UIImageView()
    private var screenDescriptionLabel = UILabel()
    private var maleButton = ActionButton(type: .custom)
    private var femaleButton = ActionButton(type: .custom)
    
    private var viewModel = OnboardingViewModel()
        
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        increasePageControlSize()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureGenderImage()
        configureScreenDescriptionLabel()
        configureMaleButton()
        configureFemaleButton()
        configurePageControl()
    }
    
    private func addSubViews() {
        view.addSubview(pageControl)
        view.addSubview(genderImageView)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(maleButton)
        view.addSubview(femaleButton)
    }
    
    private func configureView() {
        view.backgroundColor = .mainBackground
        configureBackButtonItem()
    }
    
    private func configureBackButtonItem() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func configureGenderImage() {
        genderImageView.image = R.image.gender()
        genderImageView.contentMode = .scaleAspectFill
    }
    
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.numberOfLines = 0
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.textColor = .onboardingDescriptionColor
        screenDescriptionLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.onboardingGenderEnterGender(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    // MARK: - Male button
    private func configureMaleButton() {
        maleButton.setTitle(R.string.localizable.onboardingGenderMale().uppercased(), for: .normal)
        maleButton.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        maleButton.makeWhiteState()
    }
    
    @objc private func maleButtonTapped() {
        viewModel.saveUserGender(value: 1)
        viewModel.isUserMale = true
        HapticFeedback.selection.vibrate()
        routeToNextVc()
    }
    
    // MARK: - Female button
    private func configureFemaleButton() {
        femaleButton.setTitle(R.string.localizable.onboardingGenderFemale().uppercased(), for: .normal)
        femaleButton.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        femaleButton.makeWhiteState()
    }
    
    @objc private func femaleButtonTapped() {
        viewModel.saveUserGender(value: 0)
        viewModel.isUserMale = false
        HapticFeedback.selection.vibrate()
        routeToNextVc()
    }
    
    // MARK: - Page control
    private func configurePageControl() {
        navigationItem.titleView = pageControl
        pageControl.currentPage = 0
    }
    
    private func increasePageControlSize() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
    }
    
    // MARK: - ROUTING
    func routeToNextVc() {
        let vc = UserBirthdayViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Setup constraints
extension UserGenderViewController {
    
    private func setupConstraints() {
        
        femaleButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(90)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
        }
        
        maleButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
            make.bottom.equalTo(femaleButton.snp.top).offset(-32)
        }
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(genderImageView.snp.bottom)
            make.bottom.equalTo(maleButton.snp.top)
        }
        
        genderImageView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(98)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(viewModel.topScreenImageViewConstarint)
        }
    }
}


