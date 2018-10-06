//
//  ContactPhotoCollectionViewController.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

protocol ContactPhotoCollectionViewControllerDelegate: AnyObject {
    var contactPhotoCollectionViewBeingScroll: Bool {get set}
    func contactPhotoCollectionViewDidScroll(cellPosition: IndexPath, cellOffsetPercentage: CGFloat)
}

class ContactPhotoCollectionViewController: UIViewController {
    static var photoItemSize: CGSize {
        var shorterEdge = UIScreen.main.bounds.width
        if shorterEdge > UIScreen.main.bounds.height {
            shorterEdge = UIScreen.main.bounds.height
        }
        return CGSize(width: shorterEdge / 5, height: shorterEdge / 5)
    }
    
    private var layoutInset = UIScreen.main.bounds.size.width / 2 - ContactPhotoCollectionViewController.photoItemSize.width / 2
    
    let collectionView: UICollectionView
    var controllerModel = ContactsControllerModel()
    var highlightedCellIndex = IndexPath(item: 0, section: 0)
    weak var delegate: ContactPhotoCollectionViewControllerDelegate?
    
    // MARK: - Init methods
    
    init() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = ContactPhotoCollectionViewController.photoItemSize
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: self.layoutInset, bottom: 0, right: self.layoutInset)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(controllerModel: ContactsControllerModel) {
        self.init()
        self.controllerModel = controllerModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //calculateCollectionViewInset(size: size)
    }
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.cellForItem(at: self.highlightedCellIndex)?.isSelected = true
    }
    
    // MARK: - Setup Methods
    
    private func setupCollectionView() {
        self.collectionView.decelerationRate =  UIScrollViewDecelerationRateNormal
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ProfileImageCollectionViewCell.self, forCellWithReuseIdentifier: profileImageCollectionCellIdentifier)
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        ///Setup constraints for CalendarCollectionDateCellCollectionView
        let collectionViewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.collectionView, attribute: .top, multiplier: 1.0, constant: 0)
        let collectionViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.collectionView, attribute: .left, multiplier: 1.0, constant: 0)
        let collectionViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.collectionView, attribute: .right, multiplier: 1.0, constant: 0)
        let collectionViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.collectionView, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([collectionViewTopConstraint,  collectionViewLeftConstraint, collectionViewRightConstraint, collectionViewBottomConstraint])
    }
    
    // MARK: - Private Methods
    
    private func convertIntroTableViewOffsetToPhotoCollectionViewOffset(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) -> CGPoint {
        var convertedOffset = CGPoint(x: CGFloat(cellPosition.row) *  ContactPhotoCollectionViewController.photoItemSize.width, y: 0)
        convertedOffset.x = convertedOffset.x + ContactPhotoCollectionViewController.photoItemSize.width  * cellOffsetPercentage
        return convertedOffset
    }
    
    private func nextClosestCellOffsetX(targetContentOffsetX: CGFloat) -> CGFloat {
        var convertedOffset = CGFloat(Int(targetContentOffsetX / ContactPhotoCollectionViewController.photoItemSize.width)) *  ContactPhotoCollectionViewController.photoItemSize.width
        if targetContentOffsetX - convertedOffset > ContactPhotoCollectionViewController.photoItemSize.width / 2 {
            convertedOffset = convertedOffset + ContactPhotoCollectionViewController.photoItemSize.width
        }
        return convertedOffset
    }
}

// MARK: - CollectionView Datasource

extension ContactPhotoCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileImageCollectionCellIdentifier, for: indexPath) as? ProfileImageCollectionViewCell
        cell?.profileImage.image = UIImage(named: controllerModel.contacts[indexPath.row].avatarFileName)
        return cell ?? ProfileImageCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllerModel.contacts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - CollectionView Delegate

extension ContactPhotoCollectionViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var collectionCenterPoint = self.view.convert(self.collectionView.center, to: self.collectionView)
        let cellHighlightIndex =  self.collectionView.indexPathForItem(at: collectionCenterPoint) ?? IndexPath(item: 0, section: 0)
        collectionCenterPoint.x = collectionCenterPoint.x -  ContactPhotoCollectionViewController.photoItemSize.width / 2
        let cellIndexPath = self.collectionView.indexPathForItem(at: collectionCenterPoint) ?? IndexPath(item: 0, section: 0)
        let cellScrollPercentage = (scrollView.contentOffset.x - CGFloat(cellIndexPath.row) *  ContactPhotoCollectionViewController.photoItemSize.width) /  ContactPhotoCollectionViewController.photoItemSize.width
        if self.highlightedCellIndex != cellHighlightIndex {
            self.collectionView.cellForItem(at: self.highlightedCellIndex)?.isSelected = false
            self.highlightedCellIndex = cellHighlightIndex
            self.collectionView.cellForItem(at: cellHighlightIndex)?.isSelected = true
        }
        self.delegate?.contactPhotoCollectionViewDidScroll(cellPosition: cellIndexPath, cellOffsetPercentage: cellScrollPercentage)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.contactPhotoCollectionViewBeingScroll = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee.x = nextClosestCellOffsetX(targetContentOffsetX:  targetContentOffset.pointee.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.contactPhotoCollectionViewBeingScroll = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.delegate?.contactPhotoCollectionViewBeingScroll = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.contactPhotoCollectionViewBeingScroll = true
        self.collectionView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) *  ContactPhotoCollectionViewController.photoItemSize.width, y: 0), animated: true)
    }
}
