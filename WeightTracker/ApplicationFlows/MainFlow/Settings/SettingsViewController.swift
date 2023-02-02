//
//  SettingsViewController.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 01.02.2023.
//

import UIKit
import StoreKit
import MessageUI
import HealthKit

final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  MFMailComposeViewControllerDelegate {
    
    // MARK: - Property list
    private var closeButton = UIButton(type: .system)
    private var avatarImageView = UIImageView()
    private var settingsTablewView = UITableView(frame: .zero, style: .grouped)
    private var selectorView = ChangeSettingsSelectorView()

    private var viewModel = SettingsViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configure()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewLayout()
    }
      
    // MARK: - Configure UI
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureCloseButton()
        configureAvatarImageView()
        configureSettingsTableView()
    }
    
    private func addSubViews() {
        view.addSubview(closeButton)
        view.addSubview(avatarImageView)
        view.addSubview(settingsTablewView)
    }
    
    private func configureView() {
        view.backgroundColor = .mainBackground
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - CLOSE BUTTON
    private func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.tintColor = .weightPrimary
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium, scale: .default)
        closeButton.setImage(.init(systemName: "multiply.square.fill", withConfiguration: config), for: .normal)
    }
    
    @objc private func closeButtonPressed() {
        HapticFeedback.selection.vibrate()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - AVATAR (user settings)
    private func configureAvatarImageView() {
        setAvatarImage()
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.layer.cornerCurve = .continuous
        avatarImageView.layer.shadowColor = UIColor.avatarBorderColor.cgColor
        avatarImageView.layer.shadowOffset = CGSize(width: 0, height: 12)
        avatarImageView.layer.shadowRadius = 31
        avatarImageView.layer.shadowOpacity = 0.20
        avatarImageView.layer.masksToBounds = false
        avatarImageView.isUserInteractionEnabled = true
        configureAvatarTapGesture()
    }
    
    private func setAvatarImage() {
        viewModel.isUserMale() == true ? (avatarImageView.image = R.image.avatarMan()) : (avatarImageView.image = R.image.avatarWomen())
    }
    
    private func configureAvatarTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped))
        tapGesture.cancelsTouchesInView = false
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onAvatarTapped() {
        // TODO: - Добавить возможность загружать свое фото
    }
    
    // MARK: - Settings tableView
    private func configureSettingsTableView() {
        registerCells()
        settingsTablewView.delegate = self
        settingsTablewView.dataSource = self
        settingsTablewView.backgroundColor = .clear
        settingsTablewView.showsVerticalScrollIndicator = false
        settingsTablewView.separatorStyle = .none
    }
    
    private func registerCells() {
        settingsTablewView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.settingsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.settingsData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell
        
        cell?.configure(
            titleForCell: viewModel.settingsData[indexPath.section][indexPath.row].title,
            value: viewModel.settingsData[indexPath.section][indexPath.row].value,
            cellType: viewModel.settingsData[indexPath.section][indexPath.row].type,
            isAppleHealthOn: viewModel.isAppleHealthOn,
            isHapticFeedbackOn: viewModel.isHapticFeedbackOn
        )
        
        if indexPath.item == 1 && indexPath.section == 1 {
            cell?.setSwtichState(isEnabled: HKHealthStore.isHealthDataAvailable())
        }
        
        cell?.cellWithTextfieldCallback = { [weak self] in
            guard let self = self else { return }
            let vc = ChangeSettingsViewController()
            vc.viewModel = self.viewModel
            vc.setupTitleLabel(section: indexPath.section, row: indexPath.row)
            vc.closeCallback = { [weak self] in
                self?.viewModel.configure()
                DispatchQueue.main.async {
                    self?.settingsTablewView.reloadData()
                }
            }
            self.present(vc, animated: true)
        }
        
        cell?.cellWithSelectorCallback = { [weak self] yPos, text, selectedValue in
            guard let self = self else { return }
            self.selectorView = ChangeSettingsSelectorView(yPos: yPos - 47, title: text, selectedValue: selectedValue)
            self.selectorView.selectedValueCallback = { [weak self] selectedValue, selectorType in
                self?.viewModel.saveUserData(selectorType: selectorType, value: selectedValue)
                self?.viewModel.configure()
                self?.setAvatarImage()
                DispatchQueue.main.async {
                    self?.settingsTablewView.reloadData()
                }
            }
            self.view.addSubview(self.selectorView)
        }
        
        cell?.reccomendToFriendsCallback = { [weak self] in
            guard let self = self else { return }
            let link = "www.google.com"                        // TODO: - Добавить ссылку на приложение
            let text = R.string.localizable.settingsReccomendedText()
            let url = URL(string: link)!
            let activity = UIActivityViewController(activityItems: [url, text], applicationActivities: nil)
            self.present(activity, animated: true)
        }
        
        cell?.rateAppCallback  = {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        
        cell?.contactUsCallback = { [weak self] in
            guard let self = self else { return }
            if MFMailComposeViewController.canSendMail() {
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setToRecipients(["weight.trackerrr@gmail.com"])
                mailVC.setSubject("Weight Tracker iOS Application")
                self.present(mailVC, animated: true)
            } else {
                debugPrint("Cant send mail")
            }
        }
        
        cell?.hapticFeedbackCallback = { [weak self] isSelected in
            guard let self = self else { return }
            self.viewModel.isHapticFeedbackOn = isSelected
        }
        
        cell?.appleHealthCallback = { [weak self] isSelected in
            guard let self = self else { return }
            if isSelected {
                self.viewModel.requestHealthDataPermission { isSuccess in
                    self.viewModel.isAppleHealthOn = isSuccess
                }
            } else {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            self.viewModel.isAppleHealthOn = isSelected
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let titleForSection = UILabel()
        titleForSection.attributedText = NSMutableAttributedString(string: viewModel.settingsTableSectionTitles[section], attributes: [
            NSAttributedString.Key.kern: -0.3,
            NSAttributedString.Key.font: FontService.shared.localFont(size: 20, bold: false),
            NSAttributedString.Key.foregroundColor: UIColor.weightPrimary
        ])
        view.addSubview(titleForSection)
        titleForSection.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.top.equalToSuperview().inset(8)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        38
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticFeedback.selection.vibrate()
    }

    private func updateTableViewLayout() -> Void {
        for i in settingsTablewView.visibleCells {
            settingsTablewView.bringSubviewToFront(i)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTableViewLayout()
    }
    
    private func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Setup constraints
extension SettingsViewController {
    
    private func setupConstraints() {
        
        var topInset: CGFloat = 0
        UIDevice.screenType == .less ? (topInset = 5) : (topInset = 2)
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(28)
            make.trailing.equalToSuperview().inset(30)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(14)
        }
            
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(topInset)
            make.height.equalTo(56)
            make.width.equalTo(56)
            make.leading.equalToSuperview().inset(24)
        }

        
        settingsTablewView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).inset(-16)
        }
    }
}
