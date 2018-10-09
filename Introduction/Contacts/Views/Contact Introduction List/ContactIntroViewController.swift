//
//  ContactIntroViewController.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

protocol ContactIntroViewControllerDelegate: AnyObject {
    var contactIntroTableViewBeingScroll: Bool {get set}
    func contactIntroTableViewDidScroll(cellPosition: IndexPath, cellOffsetPercentage: CGFloat)
}

class ContactIntroViewController: UIViewController {
    let tableView: UITableView
    var controllerModel = ContactsControllerModel()
    weak var delegate: ContactIntroViewControllerDelegate?
    var shadowLayer: PageFlipShadowLayer?
    
    /// Variables used to track tableview movment
    private var scrollDirection: ScrollDirection = .none
    private var cachedOffset: CGPoint = .zero
    private enum ScrollDirection {
        case up
        case down
        case none
    }
    
    // MARK: - Init methods
    
    init() {
        self.tableView = UITableView(frame: .zero)
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
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.shadowLayer = PageFlipShadowLayer(size: self.tableView.bounds.size)
        self.view.layer.addSublayer(shadowLayer!)
    }
    
    func createShadow(size: CGSize) {
        let size = self.tableView.bounds.size
        /// Center section of the shadow
        let centerShadowSection = CAShapeLayer()
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: size.width / 4, y: 0))
        shadowPath.addLine(to: CGPoint(x: size.width / 4 * 3, y: 0))
        shadowPath.move(to: CGPoint(x: size.width / 4, y: 0))
        shadowPath.addCurve(to: CGPoint(x: size.width / 4 * 3, y: 0), controlPoint1: CGPoint(x: size.width / 2, y: size.height + 2), controlPoint2: CGPoint(x: size.width / 2, y: size.height + 2))
        centerShadowSection.path = shadowPath.cgPath
        centerShadowSection.strokeColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor
        centerShadowSection.fillColor = UIColor.clear.cgColor
        centerShadowSection.lineWidth = 1.0
        
        /// Left section gradient
        let leftGradient = CAGradientLayer()
        leftGradient.startPoint = CGPoint(x: 0, y: 0)
        leftGradient.endPoint = CGPoint(x: 1, y: 0)
        leftGradient.frame = CGRect(origin: CGPoint(x: size.width / 10, y: -0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        leftGradient.colors = [UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor, UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor]
        
        
        /// right section gradient
        let rightGradient = CAGradientLayer()
        rightGradient.startPoint = CGPoint(x: 0, y: 0)
        rightGradient.endPoint = CGPoint(x: 1, y: 0)
        rightGradient.frame = CGRect(origin: CGPoint(x: size.width / 4 * 3, y: -0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        rightGradient.colors = [UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor, UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor,]
        
        
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowRadius = 1
        shadowLayer.shadowOpacity = 0.05
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        shadowLayer.insertSublayer(centerShadowSection, at: 0)
        shadowLayer.insertSublayer(leftGradient, at: 0)
        shadowLayer.insertSublayer(rightGradient, at: 0)
        //   self.collectionView.layer.addSublayer(shadowLayer)
        
        self.view.layer.addSublayer(shadowLayer)
        shadowLayer.opacity = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        fadeAnimation.repeatCount = Float.greatestFiniteMagnitude
    }
    
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.decelerationRate =  UIScrollViewDecelerationRateFast
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ContactIntroTableViewCell.self, forCellReuseIdentifier: contactIntroTableViewCellIdentifier)
        self.view.addSubview(self.tableView)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        ///Setup constraints for ContactIntroViewController
        let tableViewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 0)
        let tableViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.tableView, attribute: .left, multiplier: 1.0, constant: 0)
        let tableViewViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.tableView, attribute: .right, multiplier: 1.0, constant: 0)
        let tableViewViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([tableViewTopConstraint,  tableViewLeftConstraint, tableViewViewRightConstraint, tableViewViewBottomConstraint])
    }
    
    // MARK: - Private Methods
    
    private func convertPhotoCollectionViewOffsetToIntroTableViewOffset(cellPosition: IndexPath, cellOffsetPercentage: CGFloat) -> CGPoint {
        var convertedOffset = CGPoint(x: 0, y: self.tableView.rectForRow(at: cellPosition).origin.y)
        convertedOffset.y = convertedOffset.y +  self.tableView.rectForRow(at: IndexPath(row: cellPosition.row, section: 0)).size.height * cellOffsetPercentage
        if convertedOffset.y < 0 {
            convertedOffset.y = 0
        }
        return convertedOffset
    }
}

// MARK: - TableView Delegate and Datasource

extension ContactIntroViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactIntroTableViewCellIdentifier, for: indexPath) as? ContactIntroTableViewCell
        cell?.setupCellContent(contact: controllerModel.contacts[indexPath.row])
        return cell ?? ContactIntroTableViewCell()
    }
    
    func tableView(_ tableView: UITableView,  numberOfRowsInSection section: Int) -> Int {
        return self.controllerModel.contacts.count
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.contactIntroTableViewBeingScroll = true
        self.shadowLayer?.fadeIn()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.cachedOffset.y >= scrollView.contentOffset.y {
            self.scrollDirection = .up
        } else if cachedOffset.y < scrollView.contentOffset.y {
            self.scrollDirection = .down
        }
        self.cachedOffset = scrollView.contentOffset
        
        if let draggingCellIndexPath = self.tableView.indexPathForRow(at: scrollView.contentOffset) {
            let cellRect = self.tableView.rectForRow(at: draggingCellIndexPath)
            let cellOffsetPercentage = (scrollView.contentOffset.y - cellRect.origin.y) / cellRect.size.height
            self.delegate?.contactIntroTableViewDidScroll(cellPosition: draggingCellIndexPath, cellOffsetPercentage: cellOffsetPercentage)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let currentCellIndex = self.tableView.indexPathsForVisibleRows?.first else { return }
        var targetIndexPath = IndexPath(item: currentCellIndex.row, section: 0)
        switch scrollDirection {
        case .down:
            if (targetIndexPath.row < self.controllerModel.contacts.count - 1) {
                targetIndexPath = IndexPath(item: currentCellIndex.row + 1, section: 0)
            }
        default:
            break
        }
        let nextCellRect = self.tableView.rectForRow(at: targetIndexPath)
        targetContentOffset.pointee.y = nextCellRect.origin.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.contactIntroTableViewBeingScroll = false
        self.shadowLayer?.fadeOut()
    }
}
