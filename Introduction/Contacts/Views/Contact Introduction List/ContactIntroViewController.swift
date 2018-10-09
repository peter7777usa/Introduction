//
//  ContactIntroViewController.swift
//  Introduction
//
//  Created by Peter Fong on 10/6/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

protocol ContactIntroViewControllerDelegate: AnyObject {
    
    /// Use to lock up this tableview so nowhere else can control it
    /// -true, locked control, -false release control
    var contactIntroTableViewBeingScroll: Bool {get set}
    
    /// Let parent know the tableview current cell position and the cell offset percentage
    func contactIntroTableViewDidScroll(cellPosition: IndexPath, cellOffsetPercentage: CGFloat)
}

class ContactIntroViewController: UIViewController {
    let tableView: UITableView
    var controllerModel: ContactsControllerModel
    weak var delegate: ContactIntroViewControllerDelegate?
    var shadowLayer: PageFlipHorizontalShadowLayer?
    
    /// Variables used to track tableview movment
    private var scrollDirection: ScrollDirection = .none
    private var cachedOffset: CGPoint = .zero
    private enum ScrollDirection {
        case up
        case down
        case none
    }
    
    // MARK: - Init methods
    
    private init() {
        self.tableView = UITableView(frame: .zero)
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
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ///Apply shadow layer only after we have layout tableview's rect
        reapplyShadowLayerToIntroView(size: self.tableView.bounds.size)
    }
    
    // MARK: - Orientation Change
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        ///Destroy and reapply shadow layer because of orientation change
        reapplyShadowLayerToIntroView(size: size)
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
        setupTableViewConstraints()
    }
    
    private func setupTableViewConstraints() {
        let tableViewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 0)
        let tableViewLeftConstraint = NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: self.tableView, attribute: .left, multiplier: 1.0, constant: 0)
        let tableViewViewRightConstraint = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: self.tableView, attribute: .right, multiplier: 1.0, constant: 0)
        let tableViewViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraints([tableViewTopConstraint,  tableViewLeftConstraint, tableViewViewRightConstraint, tableViewViewBottomConstraint])
    }
    
    // MARK: - Private Methods
    
    private func reapplyShadowLayerToIntroView(size: CGSize) {
        self.shadowLayer?.removeFromSuperlayer()
        let shadowLayer = PageFlipHorizontalShadowLayer(containerViewSize: size, shadowYPosition: 0)
        self.shadowLayer = shadowLayer
        self.view.layer.addSublayer(shadowLayer)
    }
    
    /// Translate ScrollView offset into current target cell position and its offset
    /// percentage and notify parent
    private func notifyParentOfScrollingCellPositionAndOffset(scrollView: UIScrollView) {
        if let draggingCellIndexPath = self.tableView.indexPathForRow(at: scrollView.contentOffset) {
            let cellRect = self.tableView.rectForRow(at: draggingCellIndexPath)
            let cellOffsetPercentage = (scrollView.contentOffset.y - cellRect.origin.y) / cellRect.size.height
            self.delegate?.contactIntroTableViewDidScroll(cellPosition: draggingCellIndexPath, cellOffsetPercentage: cellOffsetPercentage)
        }
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
        
        /// tell the parent the tableview is being interacted, lock up
        /// so nowhere else can control the tableview
        self.delegate?.contactIntroTableViewBeingScroll = true
        
        self.shadowLayer?.fadeIn()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /// Determine dragging direction of the touch by comparing it to the cache offset
        if self.cachedOffset.y >= scrollView.contentOffset.y {
            self.scrollDirection = .up
        } else if cachedOffset.y < scrollView.contentOffset.y {
            self.scrollDirection = .down
        }
        self.cachedOffset = scrollView.contentOffset
        
        notifyParentOfScrollingCellPositionAndOffset(scrollView: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        /// This provide the paging effect by snaping the tableview to the last or next
        /// cell position based on its scrolling direction
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
        
        /// Release control of the tableview when the tableview comes to
        /// complete stop from user action
        self.delegate?.contactIntroTableViewBeingScroll = false
        
        self.shadowLayer?.fadeOut()
    }
}
