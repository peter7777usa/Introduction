//
//  ProfileImageCollectionViewCell.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

let profileImageCollectionCellIdentifier = "ProfileImageCollectionViewCell"

class ProfileImageCollectionViewCell: UICollectionViewCell {
    var profileImage = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.width / 2
                self.profileImage.layer.borderWidth = 3
            } else {
                self.profileImage.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.borderColor = UIColor.msLightBlue().cgColor
        self.profileImage.translatesAutoresizingMaskIntoConstraints = false
        self.profileImage.clipsToBounds = true
        self.contentView.addSubview(self.profileImage)
        self.setupConstraintForCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup methods
    
    private func setupConstraintForCell() {
        let profileImageCenterXConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self.profileImage, attribute: .centerX, multiplier: 1.0, constant: 0)
        let profileImageCenterYConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerY, relatedBy: .equal, toItem: self.profileImage, attribute: .centerY, multiplier: 1.0, constant: -10)
        self.contentView.addConstraints([profileImageCenterXConstraint, profileImageCenterYConstraint])
    }
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isSelected = false
    }
}
