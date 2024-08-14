//
//  PanelView.swift
//
//
//  Created by eclypse on 7/12/24.
//

import UIKit
import Combine
import SwiftUI

public class PanelView: UIViewController, ResizablePanel {
    var mainStackView: UIStackView!
    
    var _emptyStateBackgroundView: UIView?
    var _emptyViewContainerStack: UIStackView?
    
    /// maps an index to a UIView
    var panelMappings = [PanelIndex: UIView]()
    
    
    var panelWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelMinWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelMaxWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelCenterMappings = [PanelIndex: CGPoint]()
    
    var pendingViewControllers = [PanelIndex: UIViewController]()
    var pendingMinimumWidth = [PanelIndex: CGFloat]()
    var pendingMaximumWidth = [PanelIndex: CGFloat]()
    var pendingWidthFraction = [PanelIndex: CGFloat]()
    var originalFrameMappings = [PanelIndex: CGRect]()
    
    var swiftUIViewMappings = NSMapTable<PanelIndex, SwiftUIViewWrapper>(valueOptions: .weakMemory)
    
    /// maps panels to its accompanying dividers
    var dividerMappings = [PanelIndex: UIView]()
    
    
    private var hoverGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    var dividerToPanelMappings = [UIView: PanelIndex]()
    
    var panelDividerWidth: CGFloat {
        return configuration.interPanelSpacing + 2
    }
    
    private var didDisplayInitialPanel = false
    
    var _dividerConstraintIdentifier = "divider constraint:"
    
    private var _initialConfiguration = true
    private let attachedToWindowSubject = PassthroughSubject<Void, Never>()
    let panelSizeChangedSubject = PassthroughSubject<ScreenSizeChanges, Never>()
    
    // MARK: Public Members
    
    /// This publisher streams an event when the PanelView is loaded and visible.
    public var attachedToWindow: AnyPublisher<Void, Never> {
        return attachedToWindowSubject.eraseToAnyPublisher()
    }
    
    /// This publisher streams an event when the PanelView's screen size changes as observed from UITraitCollection
    public var panelSizeChanged: AnyPublisher<ScreenSizeChanges, Never> {
        return panelSizeChangedSubject.eraseToAnyPublisher()
    }
    
    /// Check this property to determine whether the PanelView's view has been loaded and is visible in the window.
    ///
    /// This property may be useful if this is the root view in your window.
    public private (set) var isAttachedToWindow = false
    
    /// children navigation controllers this panelview manages
    public var viewControllers = [PanelIndex: UINavigationController]()
    
    /// assign a delegate to get notified of events in PanelViewDelegate
    public weak var delegate: PanelViewDelegate?
    
    /// you may use this property to separate one PanelView from another
    public var identifier: String = ""
    
    /// shorthand for PanelViewConfiguration.singlePanelMode
    public var isSinglePanelMode: Bool {
        return configuration.panelMode == .single
    }
    
    public var configuration = PanelViewConfiguration() {
        didSet {
            if _initialConfiguration {
                _initialConfiguration = false
            } else {
                processConfigurationChanges(oldConfig: oldValue, newConfig: configuration)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        configurePrimaryStackView()
        
        if let validEmptyStateView = configuration.emptyStateView {
            configure(emptyStateView: validEmptyStateView)
        }
        
        configureInitialPanels()
        configureConstraintsForMainPanel()
        
        attachedToWindowSubject.send()
        isAttachedToWindow = true
        
        if !pendingViewControllers.isEmpty {
            let sortedPanels = pendingViewControllers.sorted(by: { lhs, rhs in
                return lhs.key.index < rhs.key.index
            })
            
            for (eachPanel, eachVC) in sortedPanels {
                self.show(viewController: eachVC, for: eachPanel, animated: false)
            }
            pendingViewControllers.removeAll()
        }
         
        /*
        if !pendingMinimumWidth.isEmpty {
            for (eachPanel, eachMinWidth) in pendingMinimumWidth {
                self.minimumWidth(eachMinWidth, for: eachPanel)
            }
            //pendingMinimumWidth.removeAll()
        }
        
        if !pendingMaximumWidth.isEmpty {
            for (eachPanel, eachMaxWidth) in pendingMaximumWidth {
                self.maximumWidth(eachMaxWidth, for: eachPanel)
            }
            //pendingMaximumWidth.removeAll()
        }
        
        if !pendingWidthFraction.isEmpty {
            for (eachPanel, widthFraction) in pendingWidthFraction {
                self.preferredWidthFraction(widthFraction, for: eachPanel)
            }
            //pendingWidthFraction.removeAll()
        }
        */
    }
    
    private func configureInitialPanels() {
        for index in -configuration.numberOfPanelsToPrime...configuration.numberOfPanelsToPrime {
            let onTheFlyPanelIndex = PanelIndex(index: index)
            let newlyCreatedPanel = createPanel(for: onTheFlyPanelIndex)
            mainStackView.addArrangedSubview(newlyCreatedPanel)
            newlyCreatedPanel.isHidden = true
        }
    }
    
    /// some min and max constraints for the main panel prevents UINavigationBar from 
    /// complaining that there is something wrong with the autolayout (Unsatisfiable constraint error)
    open func configureConstraintsForMainPanel() {
        let onTheFlyIndex = PanelIndex(index: 0)
        if let centerPanel = panelMappings[onTheFlyIndex] {
            NSLayoutConstraint.activate([
                centerPanel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                centerPanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
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
        
        primaryStackView.spacing = configuration.interPanelSpacing
        primaryStackView.backgroundColor = .clear
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
    
    // MARK: empty view
    func configure(emptyStateView: UIView) {
        if _emptyStateBackgroundView == nil {
            let emptyStateBackgroundView = UIView()
            emptyStateBackgroundView.backgroundColor = .systemBackground
            emptyStateBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emptyStateBackgroundView)
            
            NSLayoutConstraint.activate([
                emptyStateBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
                emptyStateBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                emptyStateBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                emptyStateBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            _emptyStateBackgroundView = emptyStateBackgroundView
        }
        
        if let alreadyConfiguredEmptyViewContainer = _emptyViewContainerStack {
            alreadyConfiguredEmptyViewContainer.subviews.forEach { $0.removeFromSuperview() }
        } else {
            let emptyViewContainer = UIStackView()
            emptyViewContainer.translatesAutoresizingMaskIntoConstraints = false
            _emptyStateBackgroundView!.addSubview(emptyViewContainer)
            
            var emptyStateViewConstraints = [NSLayoutConstraint]()
            emptyStateViewConstraints.append(emptyViewContainer.centerXAnchor.constraint(equalTo: _emptyStateBackgroundView!.centerXAnchor))
            
            if configuration.emptyViewVerticalAdjustment == 0.0 {
                emptyStateViewConstraints.append(emptyViewContainer.centerYAnchor.constraint(equalTo: _emptyStateBackgroundView!.centerYAnchor))
            } else {
                // clean the incorrect values
                let effectiveVerticalAdjustment: CGFloat
                if configuration.emptyViewVerticalAdjustment < -1.0 {
                    effectiveVerticalAdjustment = -1.0
                } else if configuration.emptyViewVerticalAdjustment > 1.0 {
                    effectiveVerticalAdjustment = 1.0
                } else {
                    effectiveVerticalAdjustment = configuration.emptyViewVerticalAdjustment
                }
                
                emptyStateViewConstraints.append(NSLayoutConstraint(item: emptyViewContainer, attribute: .centerY, relatedBy: .equal, toItem: _emptyStateBackgroundView, attribute: .centerY, multiplier: effectiveVerticalAdjustment, constant: 0))
            }
            NSLayoutConstraint.activate(emptyStateViewConstraints)
            
            _emptyViewContainerStack = emptyViewContainer
        }
        
        _emptyViewContainerStack!.addArrangedSubview(emptyStateView)
    }
    
    func removeEmptyStateView() {
        _emptyViewContainerStack = nil
        _emptyStateBackgroundView = nil
    }
    
    @discardableResult
    func add(childNavController: UINavigationController, on panel: PanelIndex) -> UIView {
        if let currentPanel = childNavController.parent?.view {
            //if the child already has a parent, it won't add anything
            return currentPanel
        }
        
        addChild(childNavController)
        viewControllers[panel] = childNavController
        
        let parentView: UIView
        
        if let existingPanel: UIView = panelMappings[panel] {
            parentView = existingPanel
        } else {
            parentView = createPanel(for: panel)
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
        
        return parentView
    }
    
    // MARK: Hover Gesture
    @objc
    func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        
        guard let hoveredSeparator = recognizer.view else { return }
        switch recognizer.state {
        case .began, .changed:
            if let highlightColor = configuration.panelDividerHoverColor {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = highlightColor
                })
            }
            if mainStackView.axis == .horizontal {
                NSCursor.resizeLeftRight.set()
            } else {
                NSCursor.resizeUpDown.set()
            }
        case .ended, .cancelled:
            if configuration.panelDividerHoverColor != nil {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        default:
            if configuration.panelDividerHoverColor != nil {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        }
        #endif
    }
    
    
    @objc
    func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        // we cannot continue if we cannot identify which panel and its associated divider is touched
        guard let draggedSeparator = gestureRecognizer.view,
              let resizedPanelIndex = dividerToPanelMappings[draggedSeparator],
              let attachedPanel = panelMappings[resizedPanelIndex] else { return }
        
        guard resizedPanelIndex.index != 0 else { return } // center panel cannot be resized
        
        // Get the changes in the X and Y directions relative to the superview's coordinate space.
        let appliedTranslation = gestureRecognizer.translation(in: draggedSeparator.superview)
        
        if gestureRecognizer.state == .began {
            // user is manipulating the first panel width
            panelCenterMappings[resizedPanelIndex] = attachedPanel.center
            originalFrameMappings[resizedPanelIndex] = attachedPanel.frame
            // print("saving resized panels initial conditions... center: \(draggedSeparator.frame.center), frame: \(draggedSeparator.frame)")
        }
        
           // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            if let minWidthConstraint = panelMinWidthMappings[resizedPanelIndex], 
               let maxWidthConstraint = panelMaxWidthMappings[resizedPanelIndex],
               let originalFrame = originalFrameMappings[resizedPanelIndex] {
                // get first panel's current frame and add the translation
                
                let proposedWidthOrHeight: CGFloat
                if mainStackView.axis == .horizontal {
                    if resizedPanelIndex.index < 0 {
                        proposedWidthOrHeight = originalFrame.width + appliedTranslation.x
                    } else {
                        proposedWidthOrHeight = originalFrame.width - appliedTranslation.x
                    }
                } else {
                    if resizedPanelIndex.index < 0 {
                        proposedWidthOrHeight = originalFrame.height + appliedTranslation.y
                    } else {
                        proposedWidthOrHeight = originalFrame.height - appliedTranslation.y
                    }
                }
                
                let finalPanelWidth: CGFloat
                if proposedWidthOrHeight < minWidthConstraint.constant {
                    finalPanelWidth = minWidthConstraint.constant
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeRight.set()
                    } else {
                        NSCursor.resizeUp.set()
                    }
                    #endif
                    
                } else if proposedWidthOrHeight > maxWidthConstraint.constant {
                    finalPanelWidth = maxWidthConstraint.constant
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeLeft.set()
                    } else {
                        NSCursor.resizeDown.set()
                    }
                    #endif
                } else {
                    // it is within the min and max
                    finalPanelWidth = proposedWidthOrHeight
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeLeftRight.set()
                    } else {
                        NSCursor.resizeUpDown.set()
                    }
                    #endif
                }
                
                if let existingWidthConstraint = panelWidthMappings[resizedPanelIndex] {
                    existingWidthConstraint.constant = finalPanelWidth
                    // print("translation applied in the x dimension: \(appliedTranslation.x), proposed width: \(proposedWidthOrHeight), final width: \(finalPanelWidth)")
                } else {
                    // print("this panel has no width constraint")
                }
                
            } else {
                // print("this panel has no min and max width constraints")
            }
            
            if gestureRecognizer.state == .ended {
                #if targetEnvironment(macCatalyst)
                NSCursor.arrow.set()
                #endif
            }
            
        } else { 
            // On cancellation, return the piece to its original location.
            
            if let originalFrame = originalFrameMappings[resizedPanelIndex] {
                attachedPanel.center = originalFrame.center
            }
            #if targetEnvironment(macCatalyst)
            NSCursor.arrow.set()
            #endif
        }
    }
}

