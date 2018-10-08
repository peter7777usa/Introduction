//
//  ContactsViewController.swift
//  Introduction
//
//  Created by Peter Fong on 10/5/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    let controllerModel = ContactsControllerModel()
    let contactPhotoCollectionViewController: ContactPhotoCollectionViewController
    let contactIntroViewController: ContactIntroViewController
    
    private var contactPhotoCollectionViewInFocus = false
    private var contactIntroTableViewInFocus = false
    
    // MARK: - Init methods
    
    init() {
        self.contactPhotoCollectionViewController = ContactPhotoCollectionViewController(controllerModel: self.controllerModel)
        self.contactIntroViewController = ContactIntroViewController(controllerModel: self.controllerModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup methods
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Contacts"
        self.edgesForExtendedLayout = []
        setupContactPhotoCollectionView()
        setupContactIntroView()
    }
    
    private func setupContactPhotoCollectionView() {
        ///Add ContactPhotoCollectionViewController as child
        self.contactPhotoCollectionViewController.delegate = self
        self.addChildViewController(self.contactPhotoCollectionViewController)
        self.view.addSubview(self.contactPhotoCollectionViewController.view)
        self.contactPhotoCollectionViewController.didMove(toParentViewController: self)
        self.contactPhotoCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        ///Setup constraints for ContactPhotoCollectionView
        let profileImageCollectionTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.contactPhotoCollectionViewController.view, attribute: .top, multiplier: 1.0, constant: 0)
        let profileImageCollectionLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.contactPhotoCollectionViewController.view, attribute: .left, multiplier: 1.0, constant: 0)
        let profileImageCollectionRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.contactPhotoCollectionViewController.view, attribute: .right, multiplier: 1.0, constant: 0)
        let profileImageCollectionHeightConstraint = NSLayoutConstraint(item: self.contactPhotoCollectionViewController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 94)
        self.view.addConstraints([profileImageCollectionTopConstraint, profileImageCollectionLeftConstraint, profileImageCollectionRightConstraint, profileImageCollectionHeightConstraint])
    }
    
    private func setupContactIntroView() {
        ///Add ContactIntroViewController as child
        self.contactIntroViewController.delegate = self
        self.addChildViewController(self.contactIntroViewController)
        self.view.addSubview(self.contactIntroViewController.view)
        self.contactIntroViewController.didMove(toParentViewController: self)
        self.contactIntroViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        ///Setup Constriants for ContactIntroView
        let contactIntroViewTopConstraint = NSLayoutConstraint(item: self.contactPhotoCollectionViewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.contactIntroViewController.view, attribute: .top, multiplier: 1.0, constant: 0)
        let contactIntroViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.contactIntroViewController.view, attribute: .left, multiplier: 1.0, constant: 0)
        let contactIntroViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.contactIntroViewController.view, attribute: .right, multiplier: 1.0, constant: 0)
        let contactIntroViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.contactIntroViewController.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([contactIntroViewTopConstraint, contactIntroViewLeftConstraint, contactIntroViewRightConstraint, contactIntroViewBottomConstraint])
    }
    
    // MARK: - Converter Methods
    
    private func convertPhotoCollectionViewOffsetToIntroTableViewOffset(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) -> CGPoint {
        var convertedOffset = CGPoint(x: 0, y: self.contactIntroViewController.tableView.rectForRow(at: cellPosition).origin.y)
        convertedOffset.y = convertedOffset.y +  self.contactIntroViewController.tableView.rectForRow(at: IndexPath(row: cellPosition.row, section: 0)).size.height * cellOffsetPercentage
        return convertedOffset
    }
    
    private func convertIntroTableViewOffsetToPhotoCollectionViewOffset(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) -> CGPoint {
        var convertedOffset = CGPoint(x: CGFloat(cellPosition.row) *  ContactPhotoCollectionViewController.photoItemSize.width, y: 0)
        convertedOffset.x = convertedOffset.x + ContactPhotoCollectionViewController.photoItemSize.width * cellOffsetPercentage
        return convertedOffset
    }
}

// MARK: - ContactIntroViewControllerDelegate

extension ContactsViewController: ContactIntroViewControllerDelegate {
    var contactIntroTableViewBeingScroll: Bool {
        get {
            return self.contactIntroTableViewInFocus
        }
        set {
            self.contactIntroTableViewInFocus = newValue
        }
    }
    
    func contactIntroTableViewDidScroll(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) {
        if self.contactIntroTableViewInFocus {
            let convertedOffset = convertIntroTableViewOffsetToPhotoCollectionViewOffset(cellPosition: cellPosition, cellOffsetPercentage: cellOffsetPercentage)
            self.contactPhotoCollectionViewController.collectionView.setContentOffset(convertedOffset, animated: false)
        }
    }
}

// MARK: - ContactPhotoCollectionViewControllerDelegate

extension ContactsViewController: ContactPhotoCollectionViewControllerDelegate {
    var contactPhotoCollectionViewBeingScroll: Bool {
        get {
            return self.contactPhotoCollectionViewInFocus
        }
        set {
            self.contactPhotoCollectionViewInFocus = newValue
        }
    }
    
    func contactPhotoCollectionViewDidScroll(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) {
        if self.contactPhotoCollectionViewInFocus {
            let convertedOffset = convertPhotoCollectionViewOffsetToIntroTableViewOffset(cellPosition: cellPosition, cellOffsetPercentage: cellOffsetPercentage)
            self.contactIntroViewController.tableView.setContentOffset(convertedOffset, animated: false)
        }
    }
}
