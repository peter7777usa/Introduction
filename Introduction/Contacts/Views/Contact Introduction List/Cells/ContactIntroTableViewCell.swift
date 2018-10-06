//
//  ContactIntroTableViewCell.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

let  contactIntroTableViewCellIdentifier = "CotactIntroTableViewCell"

class ContactIntroTableViewCell: UITableViewCell {
    var nameLabel = UILabel(frame: .zero)
    var positionLabel = UILabel(frame: .zero)
    let aboutMeLabel = UILabel(frame: .zero)
    var introLabel = UILabel(frame: .zero)
    
    // MARK: - Init methods
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.positionLabel)
        self.contentView.addSubview(self.aboutMeLabel)
        self.contentView.addSubview(self.introLabel)
        setupLabelsStyle()
        setupConstraintForCell()
        self.aboutMeLabel.text = "About me"
        self.introLabel.text = "test"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLabelsStyle() {
        self.nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.positionLabel.font = UIFont.systemFont(ofSize: 15)
        self.positionLabel.textColor = UIColor.gray
        self.aboutMeLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        self.introLabel.font = UIFont.systemFont(ofSize: 14)
        self.introLabel.textColor = UIColor.gray
        self.introLabel.numberOfLines = 0
        self.introLabel.lineBreakMode = .byWordWrapping
    }
    
    private func setupConstraintForCell() {
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.positionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.introLabel.translatesAutoresizingMaskIntoConstraints = false
        
        /// nameLabel constraint
        let nameLabelTopConstraint = NSLayoutConstraint(item: self.nameLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 25)
        let nameLabelCenterXConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self.nameLabel, attribute: .centerX, multiplier: 1.0, constant: 0)
        let nameLabelPositionLabelSpacingConstraint =  NSLayoutConstraint(item: self.nameLabel, attribute: .bottom, relatedBy: .equal, toItem: self.positionLabel, attribute: .top, multiplier: 1.0, constant: 0)
        
        ///postitionLabelConstraint
        let positionLabelCenterXConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self.positionLabel, attribute: .centerX, multiplier: 1.0, constant: 0)
        let positionLabelaboutMeLabelSpacingConstraint = NSLayoutConstraint(item: self.aboutMeLabel, attribute: .top, relatedBy: .equal, toItem: self.positionLabel, attribute: .bottom, multiplier: 1.0, constant: 30)
        
        ///aboutMeLabelConstraint
        let aboutMeLabelLeftConstraint = NSLayoutConstraint(item: self.aboutMeLabel, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 20)
        let aboutMeLabelIntroLabelSpacingConstraint =  NSLayoutConstraint(item: self.introLabel, attribute: .top, relatedBy: .equal, toItem: self.aboutMeLabel, attribute: .bottom, multiplier: 1.0, constant: 5)
        
        ///introLabelConstraint
        let introLabelLeftConstraint = NSLayoutConstraint(item: self.introLabel, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 20)
        let introLabelRightConstraint = NSLayoutConstraint(item: self.contentView, attribute: .right, relatedBy: .equal, toItem: self.introLabel, attribute: .right, multiplier: 1.0, constant: 20)
        let introLabelBottomConstraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self.introLabel, attribute: .bottom, multiplier: 1.0, constant: 265)
        self.contentView.addConstraints([nameLabelTopConstraint, nameLabelCenterXConstraint, nameLabelPositionLabelSpacingConstraint, positionLabelCenterXConstraint, positionLabelaboutMeLabelSpacingConstraint, aboutMeLabelLeftConstraint, aboutMeLabelIntroLabelSpacingConstraint, introLabelLeftConstraint,  introLabelRightConstraint, introLabelBottomConstraint])
    }
    
    // MARK: - Public Methods
    
    func setupCellContent(contact: Contact) {
        self.nameLabel.text = contact.firstName + contact.lastName
        self.positionLabel.text = contact.title
        self.introLabel.text = contact.introduction
    }
}
