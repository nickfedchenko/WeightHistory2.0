//
//  ReviewCollectionViewCell.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import UIKit

final class ReviewCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: ReviewCollectionViewCell.self)
    
    //MARK: - Property list
    private var containerView = UIView()
    private var reviewLabel = UILabel()
    private var startsImageView = UIImageView()
    private var userNameLabel = UILabel()
    private var userPhotoImageView = UIImageView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public methods
    func configure(reviewText: String, userPhoto: UIImage, userName: String) {
        setupUserNamelabel(name: userName)
        setupReviewLabel(text: reviewText)
        setupUserPhoto(photo: userPhoto)
    }
    
    //MARK: - Private methods
    private func configureUI() {
        addSubViews()
        setupConstraints()
        configureView()
        configureStarsImageView()
        configureReviewLabel()
        configureUserNameLabel()
        configureUserNameLabel()
    }
    
    private func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(reviewLabel)
        containerView.addSubview(startsImageView)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(userPhotoImageView)
    }
    
    private func configureView() {
        backgroundColor = .clear
        containerView.layer.backgroundColor = UIColor.white.cgColor
        containerView.layer.cornerCurve = .continuous
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.buttonShadowColor.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 12)
        containerView.layer.shadowRadius = 31
        containerView.layer.shadowOpacity = 0.49
        containerView.layer.masksToBounds = false
    }
    
    private func configureStarsImageView() {
        startsImageView.image = R.image.starts()
    }
    
    private func configureReviewLabel() {
        reviewLabel.font = R.font.openSansRegular(size: 17)
        reviewLabel.textAlignment = .center
        reviewLabel.numberOfLines = 0
        reviewLabel.textColor = .onboardingDescriptionColor
    }
    
    private func configureUserNameLabel() {
        userNameLabel.font = R.font.openSansSemiBold(size: 22)
        userNameLabel.textColor = .onboardingDescriptionColor
        userNameLabel.textAlignment = .center
        userNameLabel.numberOfLines = 0
    }
    
    private func configureUserPhotoImageView() {
        userPhotoImageView.layer.shadowColor = UIColor.buttonShadowColor.cgColor
        userPhotoImageView.layer.shadowOffset = CGSize(width: 0, height: 12)
        userPhotoImageView.layer.shadowRadius = 31
        userPhotoImageView.layer.shadowOpacity = 0.49
        userPhotoImageView.layer.masksToBounds = false
    }
    

    //MARK: - Other private methods
    private func setupUserNamelabel(name: String) {
        userNameLabel.text = name
    }
    
    private func setupReviewLabel(text: String) {
        reviewLabel.text = text
    }
    
    private func setupUserPhoto(photo: UIImage) {
        userPhotoImageView.image = photo
    }
}

// MARK: - Setup constraints
extension ReviewCollectionViewCell {
    
    private func setupConstraints() {
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(44)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(28)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(59.5)
        }
        
        startsImageView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        reviewLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(startsImageView.snp.bottom).offset(12)
            
        }
        
        userPhotoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-28)
            make.centerX.equalToSuperview()
            make.height.equalTo(88)
            make.width.equalTo(88)
        }
    }
}


