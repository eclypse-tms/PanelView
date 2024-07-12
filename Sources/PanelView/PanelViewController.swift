//
//  PanelViewController.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit
import Combine

public class PanelViewController: UIViewController {
    private var mainStackView: UIStackView!
    
    private var emptyViewStack: UIStackView!
    
    private var columnToViewMappings = [PanelViewIndex: UIView]()
    private var columnWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnMinWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnMaxWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnCenterMappings = [PanelViewIndex: CGPoint]()
    
    private var columnResizerMappings = [PanelViewIndex: UIView]()
    private var hoverGestureMappings = [PanelViewIndex: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [PanelViewIndex: UIHoverGestureRecognizer]()
    private var resizerToPanelMappings = [UIView: PanelViewIndex]()
    
    private let animationDuration = 0.3333
    
    var splitViewReady = PassthroughSubject<Void, Error>()
    private var isAttachedToWindow = false
    
    private var didDisplayInitialColumn = false
    
    // MARK: Public Members
    public var configuration = PanelViewConfiguration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        configurePrimaryStackView()
        configureEmptyView()
        
        splitViewReady.send()
        isAttachedToWindow = true
        
        if !pendingViewControllers.isEmpty {
            let sortedColumns = pendingViewControllers.sorted(by: { lhs, rhs in
                return lhs.key.index < rhs.key.index
            })
            
            for (eachColumn, eachVC) in sortedColumns {
                self.show(viewController: eachVC, for: eachColumn, animated: false)
            }
            pendingViewControllers.removeAll()
        }
        
        if !pendingMinimumWidth.isEmpty {
            for (eachColumn, eachMinWidth) in pendingMinimumWidth {
                self.minimumWidth(eachMinWidth, for: eachColumn)
            }
            pendingMinimumWidth.removeAll()
        }
        
        if !pendingMaximumWidth.isEmpty {
            for (eachColumn, eachMaxWidth) in pendingMaximumWidth {
                self.maximumWidth(eachMaxWidth, for: eachColumn)
            }
            pendingMaximumWidth.removeAll()
        }
        
        if !pendingWidthFraction.isEmpty {
            for (eachColumn, widthFraction) in pendingWidthFraction {
                self.preferredWidthFraction(widthFraction, for: eachColumn)
            }
            pendingWidthFraction.removeAll()
        }
    }
    
    /// adds the stackview to the view hierarchy
    private func configurePrimaryStackView() {
        let primaryStackView = UIStackView()
        switch configuration.orientation {
        case .horizontal:
            primaryStackView.axis = .horizontal
        case .vertical:
            primaryStackView.axis = .vertical
        }
        
        primaryStackView.spacing = 1.5
        primaryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(primaryStackView)
        NSLayoutConstraint.activate([
            primaryStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            primaryStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            primaryStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            primaryStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        mainStackView = primaryStackView
    }
    
    private func configureEmptyView() {
        let emptyViewContainer = UIStackView()
        emptyViewContainer.spacing = 4
        emptyViewContainer.axis = .vertical
        emptyViewContainer.alignment = .center
        
        if let validEmptyViewImage = configuration.emptyViewImage {
            let emptyViewImage = UIImageView(image: validEmptyViewImage)
            emptyViewContainer.addArrangedSubview(emptyViewImage)
            
            if let validSize = configuration.emptyViewImageDimensions {
                NSLayoutConstraint.activate([
                    emptyViewImage.widthAnchor.constraint(equalToConstant: validSize.width),
                    emptyViewImage.heightAnchor.constraint(equalToConstant: validSize.height)
                ])
            }
        }
        
        if let validEmptyViewLabel = configuration.emptyViewLabel {
            emptyViewContainer.addArrangedSubview(validEmptyViewLabel)
        }

        emptyViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(emptyViewContainer)
        NSLayoutConstraint.activate([
            emptyViewContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyViewContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        emptyViewStack = emptyViewContainer
    }
    
    private func createPanel(for index: PanelViewIndex) -> UIView {
        let aNewPanel = UIView()
        columnToViewMappings[index] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        return aNewPanel
    }
    
    private func configure(resizerView: UIView, for panelIndex: PanelViewIndex, associatedPanel: UIView) {
        
        let firstHoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(didHoverOnSeparator(_:)))
        resizerView.addGestureRecognizer(firstHoverGesture)
        
        let firstDragGesture = MacPanGestureRecognizer(target: self, action: #selector(didDragSeparator(_:)))
        resizerView.addGestureRecognizer(firstDragGesture)
        
        resizerToPanelMappings[resizerView] = panelIndex
    }
    

    /// children navigation controllers this splitview manages
    var viewControllers = [PanelViewIndex: UINavigationController]()
    
    private var pendingViewControllers = [PanelViewIndex: UIViewController]()
    private var pendingMinimumWidth = [PanelViewIndex: CGFloat]()
    private var pendingMaximumWidth = [PanelViewIndex: CGFloat]()
    private var pendingWidthFraction = [PanelViewIndex: CGFloat]()
    
    private var savedWidthFractions = [PanelViewIndex: CGFloat]()
    
    
    /// navigation controller that manages the view stack on the center view
    public var centralPanelNavController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    /// navigation controller that manages the view stack on the side view (left hand side) of the split view
    public var sideMenuController: UINavigationController? {
        return viewControllers[.navigationPanel]
    }
    
    public func topViewController(for column: PanelViewIndex) -> UIViewController? {
        return viewControllers[column]?.topViewController
    }
    
    public func isVisible(column: PanelViewIndex) -> Bool {
        if let discoveredColumn = columnToViewMappings[column] {
            return !discoveredColumn.isHidden
        } else {
            return false
        }
    }
    
    public func minimumWidth(_ width: CGFloat, for column: PanelViewIndex) {
        if isAttachedToWindow {
            columnMinWidthMappings[column]?.constant = width
        } else {
            pendingMinimumWidth[column] = width
        }
    }
    
    public func maximumWidth(_ width: CGFloat, for column: PanelViewIndex) {
        if isAttachedToWindow {
            columnMaxWidthMappings[column]?.constant = width
        } else {
            pendingMaximumWidth[column] = width
        }
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, for column: PanelViewIndex) {
        if isAttachedToWindow {
            let sanitizedFraction: CGFloat
            if fraction > 1 {
                sanitizedFraction = 1
            } else if fraction < 0 {
                sanitizedFraction = 0
            } else {
                sanitizedFraction = fraction
            }
            
            columnWidthMappings[column]?.constant = mainStackView.frame.width * sanitizedFraction
            savedWidthFractions[column] = fraction
        } else {
            pendingWidthFraction[column] = fraction
        }
    }
    
    
    public func collapseSideMenu(animated: Bool, completion: (() -> Void)?) {
        if viewControllers.count > 1 {
            hide(column: .navigationPanel, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    /// hides the third column (inspector column)
    public func collapseInspector(animated: Bool, completion: (() -> Void)?) {
        hide(column: .inspectorPanel, animated: animated, completion: completion)
    }
    
    public func push(viewController: UIViewController) {
        if let navController = viewControllers[.centerPanel] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func push(viewController: UIViewController, on column: PanelViewIndex) {
        if let navController = viewControllers[column] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func popViewController() {
        if let navController = viewControllers[.centerPanel] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func popViewController(on column: PanelViewIndex) {
        if let navController = viewControllers[column] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    
    public func hideColumn(containing viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let columnToHide: PanelViewIndex? = presents(viewController: viewController)
        
        if let discoveredColumnToHide = columnToHide {
            hide(column: discoveredColumnToHide, animated: animated, completion: completion)
        }
    }
    
    /// checks whether the provided viewController is currently being presented in one of the columns
    public func presents(viewController: UIViewController) -> PanelViewIndex? {
        var vcPresentedIn: PanelViewIndex?
        for (eachIndex, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachIndex
                break
            }
        }
        return vcPresentedIn
    }
    
    public func hide(column: PanelViewIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        _hide(column: column, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            if let previousVC = strongSelf.viewControllers[column] {
                previousVC.removeSelfFromParent()
                strongSelf.viewControllers.removeValue(forKey: column)
            }
            completion?()
        })
    }
    
    private func _hide(column: PanelViewIndex, animated: Bool, hidingCompleted: (() -> Void)?) {
        func hideAppropriateColumn() {
            columnToViewMappings[column]?.isHidden = true
        }
        
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                hideAppropriateColumn()
            }, completion: { _ in
                hidingCompleted?()
            })
        } else {
            hideAppropriateColumn()
            hidingCompleted?()
        }
    }
    
    public func show(viewController: UIViewController, for column: PanelViewIndex, animated: Bool = true) {
        func animationBlock() {
            if let aColumn = columnToViewMappings[column] {
                aColumn.isHidden = false
                aColumn.removeFromSuperview()
                let subViewIndex = calculateAppropriateIndex(for: column)
                mainStackView.insertArrangedSubview(aColumn, at: subViewIndex)
                // we need to re-establish the constraints
                //let reestablishedConstraint = inspectorColumnResizer.leftAnchor.constraint(equalTo: forthColumn.leftAnchor, constant: -1.5)
                //reestablishedConstraint.isActive = true
            }
        }
        
        if isAttachedToWindow {
            if let previousVC = viewControllers[column] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: column)
            }
            
            if mainStackView.subviews.isEmpty {
                // we are about to insert the first panel
                // hide the empty view
                self.view.sendSubviewToBack(emptyViewStack)
            }
            
            if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                add(childNavController: alreadyEmbeddedInNavController, on: column)
            } else {
                let navController = UINavigationController(rootViewController: viewController)
                add(childNavController: navController, on: column)
            }
            
            if animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    animationBlock()
                })
            } else {
                animationBlock()
            }
        } else {
            pendingViewControllers[column] = viewController
        }
    }
    
    private func calculateAppropriateIndex(for column: PanelViewIndex) -> Int {
        let sortedPanels: [PanelViewIndex] = columnToViewMappings.map { $0.key }.sorted()
        if sortedPanels.isEmpty {
            // since there are no panels, the subview index is zero
            return 0
        }
        
        var nextIndex: Int?
        for (subviewIndex, eachPanelIndex) in sortedPanels.enumerated() {
            if eachPanelIndex.index < column.index {
                continue
            } else {
                nextIndex = eachPanelIndex.index
            }
        }
        
        if let discoveredIndex = nextIndex {
            return discoveredIndex
        } else {
            // this panel must be the last panel
            return sortedPanels.endIndex
        }
    }
    
    public func reset(with singleViewController: UIViewController, on column: PanelViewIndex, animated: Bool = true) {
        reset(multiple: [singleViewController: column])
    }
    
    public func reset(multiple multiViewControllers: [UIViewController: PanelViewIndex], animated: Bool = true) {
        // first remove any existing view controllers from the parent
        for (_, vc) in viewControllers {
            vc.removeSelfFromParent()
        }
        viewControllers.removeAll(keepingCapacity: true)
        
        // reset everything
        columnToViewMappings.forEach { (_, column) in
            column.isHidden = true
        }
        
        // add the view controller one at a time by wrapping it with a nav controller
        for (eachViewController, eachColumn) in multiViewControllers {
            let navController: UINavigationController
            if let alreadyEmbeddedInNavController = eachViewController as? UINavigationController {
                navController = alreadyEmbeddedInNavController
            } else {
                navController = UINavigationController(rootViewController: eachViewController)
            }
            viewControllers[eachColumn] = navController
            if let columnToUnhide = columnToViewMappings[eachColumn] {
                add(childNavController: navController, on: eachColumn)
                columnToUnhide.isHidden = false
            }
        }
        
        if !didDisplayInitialColumn {
            didDisplayInitialColumn = true
            self.view.backgroundColor = .opaqueSeparator
        }
    }
    
    public var centerNavigationController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    private func add(childNavController: UINavigationController, on column: PanelViewIndex) {
        guard childNavController.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(childNavController)
        viewControllers[column] = childNavController
        
        let parentView: UIView
        
        if let existingPanel: UIView = columnToViewMappings[column] {
            parentView = existingPanel
        } else {
            parentView = createPanel(for: column)
        }
        
        // there is already a parent panel, simply add
        parentView.addSubview(childNavController.view)
        
        childNavController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parentView.leadingAnchor.constraint(equalTo: childNavController.view.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: childNavController.view.trailingAnchor),
            parentView.topAnchor.constraint(equalTo: childNavController.view.topAnchor),
            parentView.bottomAnchor.constraint(equalTo: childNavController.view.bottomAnchor)]
        )
        
        childNavController.didMove(toParent: self)
    }
    
    public func replaceTopViewController(with this: UIViewController, animated: Bool) {
        if let navController = viewControllers[.centerPanel] {
            navController.replaceTopViewController(with: this, animated: animated)
        }
    }
    
    @discardableResult
    public func popToViewController<T>(usingType viewControllerType: T.Type, animated: Bool) -> [UIViewController]? {
        if let navController = viewControllers[.centerPanel] {
            return navController.popToViewController(usingType: viewControllerType, animated: animated)
        }
        return nil
    }
    
    @objc
    private func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        
        switch recognizer.state {
        case .began, .changed:
            NSCursor.resizeLeftRight.set()
        case .ended, .cancelled:
            NSCursor.arrow.set()
        default:
            NSCursor.arrow.set()
        }
        #endif
    }
    
    
    @objc
    private func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        guard let draggedSeparator = gestureRecognizer.view,
              let resizedPanel = resizerToPanelMappings[draggedSeparator] else { return }
        

        // Get the changes in the X and Y directions relative to the superview's coordinate space.
        let appliedTranslation = gestureRecognizer.translation(in: draggedSeparator.superview)
        
        if gestureRecognizer.state == .began {
            // user is manipulating the first column width
            columnCenterMappings[resizedPanel] = draggedSeparator.frame.center
            // print("saving resized columns initial conditions... center: \(resizedColumn.originalCenter), frame: \(resizedColumn.originalFrame)")
        }
        
        
           // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            if let minWidthConstraint = columnMinWidthMappings[resizedPanel], let maxWidthConstraint = columnMaxWidthMappings[resizedPanel] {
                // get first column's current frame and add the translation
                
                let proposedWidth: CGFloat
                if resizedPanel.index < 0 {
                    proposedWidth = draggedSeparator.frame.width + appliedTranslation.x
                } else {
                    proposedWidth = draggedSeparator.frame.width - appliedTranslation.x
                }
                
                let finalColumnWidth: CGFloat
                if proposedWidth < minWidthConstraint.constant {
                    finalColumnWidth = minWidthConstraint.constant
                    NSCursor.resizeRight.set()
                } else if proposedWidth > maxWidthConstraint.constant {
                    finalColumnWidth = maxWidthConstraint.constant
                    NSCursor.resizeLeft.set()
                } else {
                    // it is within the min and max
                    finalColumnWidth = proposedWidth
                    NSCursor.resizeLeftRight.set()
                }
                
                columnWidthMappings[resizedPanel]?.constant = finalColumnWidth
                // print("translation applied in the x dimension: \(appliedTranslation.x), proposed width: \(proposedWidth), final width: \(finalColumnWidth)")
            } else {
                // print("dragged view is not the first column")
            }
            
            if gestureRecognizer.state == .ended {
                NSCursor.arrow.set()
            }
            
        } else { // On cancellation, return the piece to its original location.
            // print("resizing is canceled")
            draggedSeparator.center = .zero
            NSCursor.arrow.set()
        }
        #endif
    }
}

