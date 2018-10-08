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
    
    func createCollectionViewShadowLayer() {
        let size = collectionView.bounds.size
        
        /// Center section of the shadow
        let centerShadowSection = CAShapeLayer()
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: size.width / 10, y: size.height))
        shadowPath.addLine(to: CGPoint(x: size.width / 4 * 3, y: size.height))
        shadowPath.move(to: CGPoint(x: size.width / 4, y: size.height))
        shadowPath.addCurve(to: CGPoint(x: size.width / 4 * 3, y: size.height), controlPoint1: CGPoint(x: size.width / 2, y: size.height + 1), controlPoint2: CGPoint(x: size.width / 2, y: size.height + 1))
        centerShadowSection.path = shadowPath.cgPath
        centerShadowSection.strokeColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor
        centerShadowSection.fillColor = UIColor.clear.cgColor
        centerShadowSection.lineWidth = 1.0
        
        /// Left section gradient
        let leftGradient = CAGradientLayer()
        leftGradient.startPoint = CGPoint(x: 0, y: 0)
        leftGradient.endPoint = CGPoint(x: 1, y: 0)
        leftGradient.frame = CGRect(origin: CGPoint(x: size.width / 10, y: size.height - 0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        leftGradient.colors = [UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor, UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor]
        
        /// right section gradient
        let rightGradient = CAGradientLayer()
        rightGradient.startPoint = CGPoint(x: 0, y: 0)
        rightGradient.endPoint = CGPoint(x: 1, y: 0)
        rightGradient.frame = CGRect(origin: CGPoint(x: size.width / 4 * 3, y: size.height - 0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        rightGradient.colors = [UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor, UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor,]
        rightGradient.shadowRadius = 1
        
        let shadowSubLayer = createShadowLayer()
        shadowSubLayer.insertSublayer(centerShadowSection, at: 0)
        shadowSubLayer.insertSublayer(leftGradient, at: 0)
        shadowSubLayer.insertSublayer(rightGradient, at: 0)
        collectionView.layer.addSublayer(shadowSubLayer)
        shadowSubLayer.opacity = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        fadeAnimation.repeatCount = Float.greatestFiniteMagnitude
        
         shadowSubLayer.add(fadeAnimation, forKey: "FadeAnimation")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.cellForItem(at: self.highlightedCellIndex)?.isSelected = true

        createCollectionViewShadowLayer()
        
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
        
        ///Setup constraints for CollectionView
        let collectionViewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.collectionView, attribute: .top, multiplier: 1.0, constant: 0)
        let collectionViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.collectionView, attribute: .left, multiplier: 1.0, constant: 0)
        let collectionViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.collectionView, attribute: .right, multiplier: 1.0, constant: 0)
        let collectionViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.collectionView, attribute: .bottom, multiplier: 1.0, constant: 4)
        
        self.view.addConstraints([collectionViewTopConstraint,  collectionViewLeftConstraint, collectionViewRightConstraint, collectionViewBottomConstraint])
        
//        self.collectionView.layer.shadowColor = UIColor.black.cgColor
//        self.collectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.collectionView.layer.shadowOpacity = 0.7
//        self.collectionView.layer.shadowRadius = 5
//        self.collectionView.layer.masksToBounds = false
//
//        let size = collectionView.bounds.size
//        let curlFactor: CGFloat = 15.0
//        let shadowDepth: CGFloat = 5.0
//
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: size.width, y: 0))
//        path.addLine(to: CGPoint(x: size.width, y: size.height + shadowDepth))
//        path.addLine(to: CGPoint(x: 0, y: size.height * shadowDepth))
//        path.addCurve(to: CGPoint(x: 0, y: size.height + shadowDepth), controlPoint1: CGPoint(x: size.width - curlFactor, y: size.height + shadowDepth - curlFactor), controlPoint2: CGPoint(x: curlFactor, y: size.height + shadowDepth - curlFactor))
//
//        self.collectionView.layer.shadowPath = path.cgPath
        

        
    }
    
    func createShadowLayer() -> CALayer {
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowRadius = 1
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        return shadowLayer
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
