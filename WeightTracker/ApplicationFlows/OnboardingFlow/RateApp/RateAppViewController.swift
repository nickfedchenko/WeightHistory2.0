//
//  RateAppViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import UIKit
import StoreKit

final class RateAppViewController: UIViewController {
    
    // MARK: - Property list
    private var rateImageView = UIImageView()
    private var closeButton = UIButton(type: .custom)
    private var screenDescriptionLabel = UILabel()
    private var rateButton = ActionButton(type: .system)
    private var pageControl = UIPageControl()
    private var reviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var viewModel = RateAppViewModel()
        
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        configureView()
        setupConstraints()
        configureReviewCollectionView()
        configureScreenDescriptionLabel()
        configureRateButton()
        configureCloseButton()
        configureRateImageView()
        configurePageControl()
    }
    
    private func addSubViews() {
        view.addSubview(rateImageView)
        view.addSubview(closeButton)
        view.addSubview(screenDescriptionLabel)
        view.addSubview(reviewCollectionView)
        view.addSubview(rateButton)
        view.addSubview(pageControl)
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundMainColor
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureRateImageView() {
        rateImageView.image = R.image.union()
    }
    
    // MARK: - COLLECTION VIEW
    private func configureReviewCollectionView() {
        registerCells()
        reviewCollectionView.delegate = self
        reviewCollectionView.dataSource = self
        reviewCollectionView.backgroundColor = .clear
        reviewCollectionView.isPagingEnabled = true
        reviewCollectionView.showsHorizontalScrollIndicator = false

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        reviewCollectionView.setCollectionViewLayout(layout, animated: true)
        reviewCollectionView.layer.masksToBounds = false
    }
    
    private func registerCells() {
        reviewCollectionView.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: ReviewCollectionViewCell.identifier)
    }
    
    // MARK: - SCREEN DESCRIPTION
    private func configureScreenDescriptionLabel() {
        screenDescriptionLabel.textAlignment = .center
        screenDescriptionLabel.text = R.string.localizable.onboardingRateRateOurApp()
        screenDescriptionLabel.font = R.font.openSansSemiBold(size: 22)
        screenDescriptionLabel.textColor = .promtBigTitle
        screenDescriptionLabel.numberOfLines = 0
    }
    
    // MARK: - PAGE CONTROL
    private func configurePageControl() {
        pageControl.numberOfPages = viewModel.reviews.count
        pageControl.tintColor = .clear
        pageControl.pageIndicatorTintColor = .onboardingPageControlSecondary
        pageControl.currentPageIndicatorTintColor = .onboardingPageControlCurrent
        pageControl.currentPage = 0
        pageControl.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        pageControl.isUserInteractionEnabled = false
    }
    
    // MARK: - RATE BUTTON
    private func configureRateButton() {
        rateButton.makeMainState()
        rateButton.setTitle(R.string.localizable.onboardingRateRate().uppercased(), for: .normal)
        rateButton.addTarget(self, action: #selector(rateButtonPressed), for: .touchUpInside)
    }
    
    @objc private func rateButtonPressed() {
        HapticFeedback.medium.vibrate()
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .onboardCloseButton
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        HapticFeedback.selection.vibrate()
        routeToNextVc()
    }
    
    // MARK: - ROUTING
    private func routeToNextVc() {
        if viewModel.isSubscriptionActive() {
            routToMainScreen()
        } else {
            let vc = PaywallViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func routToMainScreen() {
//        let vc = MainScreenViewController()
        let vc = UIViewController()
        if let navigationController = navigationController {
            vc.navigationController?.isNavigationBarHidden = true
            navigationController.setViewControllers([vc], animated: true)
            UIView.transition(with: navigationController.view, duration: 0.3, options: [.transitionCrossDissolve], animations: nil)
        } else {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = vc
                UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: nil)
            }
        }
    }
}

// MARK: - ReviewCollectionView DataSource & Delegate
extension RateAppViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        999
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.identifier, for: indexPath) as? ReviewCollectionViewCell
        if indexPath.item <= 2 {
            cell?.configure(
                reviewText: viewModel.reviews[indexPath.item].reviewText,
                userPhoto: viewModel.reviews[indexPath.item].userPhoto,
                userName: viewModel.reviews[indexPath.item].userName
            )
        } else {
            cell?.configure(
                reviewText: viewModel.reviews[indexPath.item % viewModel.reviews.count].reviewText,
                userPhoto: viewModel.reviews[indexPath.item % viewModel.reviews.count].userPhoto,
                userName: viewModel.reviews[indexPath.item % viewModel.reviews.count].userName
            )
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: view.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int(scrollView.contentOffset.x / width) % viewModel.reviews.count
    }
}

// MARK: - Setup constraints
extension RateAppViewController {
    
    private func setupConstraints() {
        
        rateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(viewModel.topRateImageConstraint)
            make.height.equalTo(94)
            make.width.equalTo(98)
            make.centerX.equalToSuperview()
        }
        
        screenDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(rateImageView.snp.bottom).offset(viewModel.topDescriptionConstraint)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        rateButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(viewModel.bottomRateButtonConstraint)
            make.height.equalTo(72)
        }
        
        reviewCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(290)
            if UIDevice.screenType == .less {
                make.bottom.equalTo(rateButton.snp.top).inset(-60)
            } else {
                make.centerY.equalToSuperview()
            }
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(reviewCollectionView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(viewModel.topCloseButtonConstraint)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
    }
}
