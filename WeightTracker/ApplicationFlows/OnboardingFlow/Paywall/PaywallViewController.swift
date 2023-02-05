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
    private var restorePurchaseButton = UILabel()
    private var privacyButton = UILabel()
    private var termsButton = UILabel()
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
        configureRestorePurchaseButton()
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
        contentView.addSubview(restorePurchaseButton)
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
    
    // MARK: - PRIVACY BUTTON
    private func configurePrivacyButton() {
        let attrTitle = NSMutableAttributedString(
            string: R.string.localizable.subscriptionPrivacy(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 10 : 12) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark,
            ]
        )
        privacyButton.attributedText = attrTitle
        privacyButton.numberOfLines = 0
        privacyButton.isUserInteractionEnabled = true
        configurePrivacyTapGesture()
    }
    
    private func configurePrivacyTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPrivacyPressed))
        tapGesture.cancelsTouchesInView = false
        privacyButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onPrivacyPressed() {
        if let url = URL(string: "https://docs.google.com/document/d/13OYuleJmzYPWYWb_ynSS-faqfBPaz45A-xsDpkRr-vs/edit") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - TERMS BUTTON
    private func configureTermsButton() {
        let attrTitle = NSMutableAttributedString(
            string: R.string.localizable.subscriptionTerms(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 10 : 12) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark
            ]
        )
        termsButton.attributedText = attrTitle
        termsButton.textAlignment = .right
        termsButton.numberOfLines = 0
        termsButton.isUserInteractionEnabled = true
        configureTermsTapGesture()
    }
    
    private func configureTermsTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTermsPressed))
        tapGesture.cancelsTouchesInView = false
        termsButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onTermsPressed() {
        if let url = URL(string: "https://docs.google.com/document/d/13jBN6nyTQtZUgU5F4wkWmTrQ0qvQEfEH2ZCHO7QMn6k/edit") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - RESTORE PURChASE BUTTON
    private func configureRestorePurchaseButton() {
        let attrTitle = NSMutableAttributedString(
            string: R.string.localizable.subscriptionRestorePurchase(),
            attributes: [
                NSAttributedString.Key.kern: 0.12,
                NSAttributedString.Key.font: R.font.openSansMedium(size: Locale.isLanguageRus ? 12 : 14) ?? UIFont.systemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.basicDark
            ]
        )
        restorePurchaseButton.textAlignment = .center
        restorePurchaseButton.numberOfLines = 0
        restorePurchaseButton.attributedText = attrTitle
        restorePurchaseButton.isUserInteractionEnabled = true
        configureRestorePurchaseTapGesture()
    }
    
    @objc private func restorePurchasePressed() {
        Apphud.restorePurchases { subscriptions, purchases, error in
            if Apphud.hasActiveSubscription() {
                // проверяем есть ли вдруг активные подписки, если есть просто переходим на главный экран
                self.routeToMainStage()
            } else {
                if subscriptions?.first?.isActive() ?? false {
                    // если удалось восстановить подписку, показываем алерт что подписка восстановлена и отправляем после алерта на главный
                    self.showSimpleAlertWithCompletion(titleText: R.string.localizable.alertMessagePurchaseRestored()) { _ in
                        self.routeToMainStage()
                    }
                } else {
                    // если нет подписки показываем алерт что подписка не восстановлена и просто закрываем алерт и возвращаемся на пейвол
                    self.showSimpleAlert(titleText: R.string.localizable.alertMessagePurchasesNotFound())
                }
            }
        }
    }
    
    private func configureRestorePurchaseTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(restorePurchasePressed))
        tapGesture.cancelsTouchesInView = false
        restorePurchaseButton.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - LABELS
    private func configureScreenTitleLabel() {
        screenTitleLabel.font = FontService.shared.localFont(size: 32, bold: true)
        screenTitleLabel.textColor = .promtBigTitle
        screenTitleLabel.numberOfLines = 0
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.attributedText = NSMutableAttributedString(
            string: R.string.localizable.subscriptionBenefitsControlWeight(),
            attributes: [NSAttributedString.Key.kern: -0.3]
        )
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
    
    // MARK: - IMAGES
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
        }
        
        privacyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(startButton.snp.bottom).inset(-32)
            make.width.equalTo(120)
        }
        
        termsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(startButton.snp.bottom).inset(-32)
            make.width.equalTo(120)
        }
        
        viewForCancelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startButton.snp.bottom).inset(-10)
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
        
        restorePurchaseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            if Locale.isLanguageRus {
                make.top.equalTo(viewForCancelLabel.snp.bottom).inset(-30)
            } else {
                make.top.equalTo(viewForCancelLabel.snp.bottom).inset(-10)
            }
        }
    }
}
