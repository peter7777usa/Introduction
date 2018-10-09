//
//  ContactPhotoCollectionViewController.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

protocol ContactPhotoCollectionViewControllerDelegate: AnyObject {
    
    /// Use to lock up this collection view when user is scrolling
    /// so nowhere else can control it
    /// -true, locked control, -false release control
    var contactPhotoCollectionViewBeingScroll: Bool {get set}
    
    /// Let parent know the collectionview current cell position and the cell offset percentage
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
    
    let collectionView: UICollectionView
    var controllerModel: ContactsControllerModel
    weak var delegate: ContactPhotoCollectionViewControllerDelegate?
    
    /// Keep reference to highlighted cell index so we can deselect
    private var highlightedCellIndex = IndexPath(item: 0, section: 0)
    
    /// Use to hold layout inset of collectionview and recalculate
    /// once orientation changed
    private var layoutInset = UIScreen.main.bounds.size.width / 2 - ContactPhotoCollectionViewController.photoItemSize.width / 2
    
    // MARK: - Init methods
    
    private init() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = ContactPhotoCollectionViewController.photoItemSize
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: self.layoutInset, bottom: 0, right: self.layoutInset)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.controllerModel = ContactsControllerModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(controllerModel: ContactsControllerModel) {
        self.init()
        self.controllerModel = controllerModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    // MARK: - Orientation Change Method
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layoutInset = size.width / 2 - ContactPhotoCollectionViewController.photoItemSize.width / 2
        self.collectionView.collectionViewLayout.invalidateLayout()
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
        self.collectionView.clipsToBounds = false
        setupCollectionViewConstraint()
    }
    
    private func setupCollectionViewConstraint () {
        let collectionViewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.collectionView, attribute: .top, multiplier: 1.0, constant: 0)
        let collectionViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.collectionView, attribute: .left, multiplier: 1.0, constant: 0)
        let collectionViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.collectionView, attribute: .right, multiplier: 1.0, constant: 0)
        let collectionViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.collectionView, attribute: .bottom, multiplier: 1.0, constant: 10)
        self.view.addConstraints([collectionViewTopConstraint,  collectionViewLeftConstraint, collectionViewRightConstraint, collectionViewBottomConstraint])
    }
    
    // MARK: - Private Methods
    
    private func convertIntroTableViewOffsetToPhotoCollectionViewOffset(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) -> CGPoint {
        var convertedOffset = CGPoint(x: CGFloat(cellPosition.row) *  ContactPhotoCollectionViewController.photoItemSize.width, y: 0)
        convertedOffset.x = convertedOffset.x + ContactPhotoCollectionViewController.photoItemSize.width  * cellOffsetPercentage
        return convertedOffset
    }
    
    /// Use to snap cell position to the closest position of a cell so the
    /// deceleration to full stop of the collection view wont end up in between
    /// cell
    ///
    /// - Parameters:
    ///   - targetContentOffsetX: the original position the collection intended to end up
    /// - Returns: The after calculation closet cell position we want it to end up
    private func nextClosestCellOffsetX(targetContentOffsetX: CGFloat) -> CGFloat {
        var convertedOffset = CGFloat(Int(targetContentOffsetX / ContactPhotoCollectionViewController.photoItemSize.width)) *  ContactPhotoCollectionViewController.photoItemSize.width
        if targetContentOffsetX - convertedOffset > ContactPhotoCollectionViewController.photoItemSize.width / 2 {
            convertedOffset = convertedOffset + ContactPhotoCollectionViewController.photoItemSize.width
        }
        return convertedOffset
    }
    
    /// Translate ScrollView offset into current target cell position and its offset
    /// percentage and notify parent
    private func notifyParentOfScrollingCellPositionAndOffset(scrollView: UIScrollView) {
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

// MARK: - CollectionViewDelegateFlowLayout Delegate

extension ContactPhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: self.layoutInset, bottom: 0, right: self.layoutInset)
    }
}

// MARK: - CollectionView Delegate

extension ContactPhotoCollectionViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifyParentOfScrollingCellPositionAndOffset(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        /// User begin dragging the collection view, retain control so
        /// nowhere else can control this collection view
        self.delegate?.contactPhotoCollectionViewBeingScroll = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        /// This will make sure it always end up at the begining of a introduction, not
        /// in between
        targetContentOffset.pointee.x = nextClosestCellOffsetX(targetContentOffsetX:  targetContentOffset.pointee.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        /// Release control of the collection view when it comes to
        /// to full stop from deceleration because of user's action
        self.delegate?.contactPhotoCollectionViewBeingScroll = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        /// When user select a cell on the collection view, there is an animation
        /// that it goes from indexA -> indexB, only release control of the collection view
        /// once the animation triggered by the user is completed
        self.delegate?.contactPhotoCollectionViewBeingScroll = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /// User select the collection view cell, lock up collection view
        /// until the the scroll to item animation is completed
        /// look up scrollViewDidEndScrollingAnimation
        self.delegate?.contactPhotoCollectionViewBeingScroll = true
        self.collectionView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) *  ContactPhotoCollectionViewController.photoItemSize.width, y: 0), animated: true)
    }
}
