//
//  PaywallViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import ApphudSDK
import UIKit

final class PaywallViewController: UIViewController {
    
    // MARK: - Property list
    private var mainScrollView = UIScrollView()
    private var contentView = UIView()
    
    private var screenImage = UIImageView()
    private var closeButton = UIButton(type: .custom)
    private var screenTitleLabel = UILabel()
    private var benefitsTableView = UITableView()
    private var startButton = ActionButton(type: .system)
    private var lockImageView = UIImageView()
    private var cancelLabel = UILabel()
    private var privacyButton = UIButton(type: .system)
    private var termsButton = UIButton(type: .system)
    private var viewForCancelLabel = UIView()
    private var paymentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var viewModel = SubscriptionViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureReloadHandler()
    }
    
    // MARK: - Configure UI
    private func configureUI() {
        addSubviews()
        setupConstraints()
        configureScreenTitleLabel()
        configureScreenImageView()
        configureView()
        registerCells()
        configureBenefitTableView()
        configureCollectionView()
        configureStartButton()
        configurePrivacyButton()
        configureTermsButton()
        configureCancelLabel()
        configureLockImageView()
        configureCloseButton()
    }
    
    private func addSubviews() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(screenImage)
        contentView.addSubview(screenTitleLabel)
        contentView.addSubview(benefitsTableView)
        contentView.addSubview(paymentCollectionView)
        contentView.addSubview(startButton)
        contentView.addSubview(privacyButton)
        contentView.addSubview(termsButton)
        contentView.addSubview(viewForCancelLabel)
        viewForCancelLabel.addSubview(lockImageView)
        viewForCancelLabel.addSubview(cancelLabel)
        mainScrollView.showsVerticalScrollIndicator = true
    }
    
    private func configureView() {
        view.backgroundColor = .mainBackground
        viewForCancelLabel.backgroundColor = .clear
        self.navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureScreenTitleLabel() {
        screenTitleLabel.font = R.font.promptExtraBold(size: 32)
        screenTitleLabel.textColor = .promtBigTitle
        screenTitleLabel.numberOfLines = 0
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.subscriptionBenefitsControlWeight(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
    }
    
    private func configurePrivacyButton() {
        let attrTitle = NSMutableAttributedString(
            string: R.string.localizable.subscriptionPrivacy(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 10 : 12) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark
            ]
        )
        privacyButton.setAttributedTitle(attrTitle, for: .normal)
    }
    
    private func configureTermsButton() {
        let attrTitle = NSMutableAttributedString(
            string: R.string.localizable.subscriptionTerms(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 10 : 12) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark
            ]
        )
        termsButton.setAttributedTitle(attrTitle, for: .normal)
    }
    
    private func configureCancelLabel() {
        let attrText = NSMutableAttributedString(
            string: R.string.localizable.subscriptionCancelAnytime(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: 15) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark
            ]
        )
        cancelLabel.attributedText = attrText
    }
    
    private func configureScreenImageView() {
        screenImage.image = R.image.subscriptionImage()
        screenImage.contentMode = .scaleAspectFit
    }
    
    private func configureLockImageView() {
        lockImageView.image = R.image.lock()
        lockImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - TABLE & COLLECTION VIEW CONFIGURATION
    private func configureBenefitTableView() {
        benefitsTableView.dataSource = self
        benefitsTableView.separatorStyle = .none
        benefitsTableView.isUserInteractionEnabled = false
        benefitsTableView.backgroundColor = .white
        benefitsTableView.clipsToBounds = true
        benefitsTableView.layer.cornerRadius = 16
        benefitsTableView.layer.cornerCurve = .continuous
    }
    
    private func configureCollectionView() {
        paymentCollectionView.dataSource = self
        paymentCollectionView.delegate = self
        paymentCollectionView.backgroundColor = .clear
        paymentCollectionView.isScrollEnabled = false
        paymentCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
    }
    
    private func registerCells() {
        benefitsTableView.register(BenefitsTableViewCell.self, forCellReuseIdentifier: BenefitsTableViewCell.identifier)
        paymentCollectionView.register(PaymentCollectionViewCell.self, forCellWithReuseIdentifier: PaymentCollectionViewCell.identifier)
    }
    
    // MARK: - START BUTTON
    private func configureStartButton() {
        startButton.setTitle(R.string.localizable.buttonsLetsStart(), for: .normal)
        startButton.makeMainState()
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
    
    @objc private func startButtonPressed() {
        HapticFeedback.heavy.vibrate()
        guard let product = viewModel.getProductToPurchase() else { return }
        Apphud.purchase(product) { [weak self] result in
            if let error = result.error {
                self?.showSimpleAlert(titleText: "Error performing purchase with \(error.localizedDescription)")
            }
            if let subscription = result.subscription, subscription.isActive() {
                self?.routeToMainStage()
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                self?.routeToMainStage()
            } else {
                if Apphud.hasActiveSubscription() {
                    self?.routeToMainStage()
                }
            }
        }
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .closeButtonGray
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        HapticFeedback.selection.vibrate()
        routeToMainStage()
    }
    
    // MARK: - ROUTING
    private func routeToMainStage() {
        let vc = MainStageViewController()
        if let navigationController = navigationController {
            vc.navigationController?.isNavigationBarHidden = true
            navigationController.setViewControllers([vc], animated: true)
            UIView.transition(with: navigationController.view, duration: 0.3, options: [.transitionCrossDissolve], animations: nil)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - TableView Data Source
extension PaywallViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.benefitCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BenefitsTableViewCell.identifier, for: indexPath) as? BenefitsTableViewCell
        cell?.configure(withTitle: viewModel.benefitCells[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        36
    }
}

// MARK: - CollectionView Data Source
extension PaywallViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfProducts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCollectionViewCell.identifier, for: indexPath) as? PaymentCollectionViewCell
        let model = viewModel.makeModelForProduct(at: indexPath)
        cell?.configure(with: model)
        if indexPath.row == 0 {
            cell?.isSelected = true
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = view.frame.width - 48
        return CGSize.init(width: itemWidth, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticFeedback.selection.vibrate()
        viewModel.selectedIndex = indexPath.item
    }
    
    private func configureReloadHandler() {
        viewModel.reloadHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.paymentCollectionView.reloadData()
            }
        }
    }
}

// MARK: - Setup constraints
extension PaywallViewController {
    
    private func setupConstraints() {
        
        mainScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        screenImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(302)
            make.width.equalTo(252)
            make.top.equalToSuperview().inset(-60)
        }
        
        screenTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(benefitsTableView.snp.top)
            make.width.equalTo(366)
        }
        
        benefitsTableView.snp.makeConstraints { make in
            make.top.equalTo(screenImage.snp.bottom).inset(4)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(144)
        }
        
        paymentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(benefitsTableView.snp.bottom).inset(-14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(230)
        }
        
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(72)
            make.top.equalTo(paymentCollectionView.snp.bottom).inset(-27)
            make.bottom.equalTo(viewForCancelLabel.snp.top).inset(-20)
        }
        
        privacyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(32)
        }
        
        termsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(32)
        }
        
        viewForCancelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startButton.snp.bottom).inset(-20)
            make.bottom.equalToSuperview().inset(50)
        }
        
        lockImageView.snp.makeConstraints { make in
            make.width.equalTo(14)
            make.height.equalTo(12)
            make.centerY.equalTo(cancelLabel.snp.centerY)
            make.trailing.equalTo(cancelLabel.snp.leading).inset(-10)
            make.leading.equalToSuperview()
        }
        
        cancelLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(28)
            make.trailing.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(8)
        }
    }
}
