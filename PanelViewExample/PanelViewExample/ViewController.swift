//
//  ViewController.swift
//  PanelViewExample
//
//  Created by eclypse on 7/12/24.
//

import UIKit
import PanelView
import Combine
import MultiSelectSegmentedControl

class ViewController: UIViewController {
    
    @IBOutlet private var buttonGroup: UIStackView!
    @IBOutlet private var buttonGroupContainer: UIView!
    
    @IBOutlet private var lhsMultiSelect: MultiSelectSegmentedControl!
    @IBOutlet private var rhsMultiSelect: MultiSelectSegmentedControl!
    @IBOutlet private var showCenterPanel: UISwitch!
    
    @IBOutlet private var singlePanelMode: UISwitch!
    @IBOutlet private var changeOrientationSegments: UISegmentedControl!
    @IBOutlet private var showEmptyView: UISwitch!
    
    private var cancellables = Set<AnyCancellable>()
    private var panelView: PanelView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addPanelView()
        // configureBindings()
        
        lhsMultiSelect.items = ["5", "4", "3", "2", "1"]
        lhsMultiSelect.delegate = self
        
        rhsMultiSelect.items = ["1", "2", "3", "4", "5"]
        rhsMultiSelect.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func addPanelView() {
        panelView = PanelView()
        panelView.delegate = self
        
        var customConfig = PanelViewConfiguration()
        customConfig.numberOfPanelsToPrime = 5
        customConfig.orientation = .horizontal
        customConfig.allowsUIPanelSizeAdjustment = true
        customConfig.interPanelSpacing = 20
        customConfig.panelMode = .multi
        customConfig.autoReleaseViewControllers = true
        customConfig.emptyStateView = configureEmptyView()
        
        panelView.configuration = customConfig
        
        
        for index in -panelView.configuration.numberOfPanelsToPrime...panelView.configuration.numberOfPanelsToPrime {
            if index == 0 {
                continue
            }
            let onTheFlyPanelIndex = PanelIndex(index: index)
            panelView.minimumWidth(100, for: onTheFlyPanelIndex)
            panelView.maximumWidth(600, for: onTheFlyPanelIndex)
            panelView.preferredWidthFraction(0.1, at: index)
        }
        
        
        addPanelViewAsChildView(panelView)
        
        let mainVC = UIViewController()
        mainVC.navigationController?.setNavigationBarHidden(true, animated: false)
        mainVC.view.backgroundColor = .systemBackground
        addLabel(to: mainVC, labelText: "Main")
        
        panelView.show(viewController: mainVC, for: .main)
    }
    
    private func configureEmptyView() -> UIView {
        let emptyStackView = UIStackView()
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.spacing = 8
        
        // image for the empty state
        let emptyViewImage = UIImageView(image: UIImage(systemName: "viewfinder"))
        NSLayoutConstraint.activate([
            emptyViewImage.widthAnchor.constraint(equalToConstant: 60),
            emptyViewImage.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        emptyStackView.addArrangedSubview(emptyViewImage)
        
        
        let customLabel = UILabel()
        customLabel.text = "Nothing to see here"
        customLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        emptyStackView.addArrangedSubview(customLabel)
        
        let customLabel2 = UILabel()
        customLabel2.text = "This is a demo empty view"
        customLabel2.font = UIFont.preferredFont(forTextStyle: .body)
        emptyStackView.addArrangedSubview(customLabel2)
        
        return emptyStackView
    }
    
    private func configureBindings() {
        panelView.attachedToWindow
            .sink { _ in
                // PanelView is loaded and visible
            }.store(in: &cancellables)
        
        panelView.panelSizeChanged
            .sink { changes in
                // screen size changed
            }.store(in: &cancellables)
    }
    
    @IBAction
    private func didSwitchOrientation(_ sender: UISegmentedControl) {
        if panelView.configuration.orientation == .horizontal {
            panelView.configuration.orientation = .vertical
        } else {
            panelView.configuration.orientation = .horizontal
        }
    }
    
    @IBAction
    private func switchToSinglePanelMode(_ sender: UISwitch) {
        let newPanelMode: PanelMode = sender.isOn ? .single : .multi
        panelView.configuration.panelMode = newPanelMode
        
        if sender.isOn {
            // we switched to single panel mode
            // deselect everything
            if let panelWithHighestIndex = panelView.visiblePanels.last {
                // we need to deselect the rest of the buttons from the multi select segments
                lhsMultiSelect.selectAllSegments(false)
                rhsMultiSelect.selectAllSegments(false)
                if panelWithHighestIndex.index < 0 {
                    let segmentToSelect = lhsMultiSelect.segments.count + panelWithHighestIndex.index
                    lhsMultiSelect.selectedSegmentIndex = segmentToSelect
                    showCenterPanel.isOn = false
                } else if panelWithHighestIndex.index == 0 {
                    showCenterPanel.isOn = true
                } else {
                    let segmentToSelect = panelWithHighestIndex.index - 1
                    rhsMultiSelect.selectedSegmentIndex = segmentToSelect
                    showCenterPanel.isOn = false
                }
            }
            
            // we to prevent multiple segments from being selected since we are only showing a single panel
            lhsMultiSelect.allowsMultipleSelection = false
            rhsMultiSelect.allowsMultipleSelection = false
        } else {
            // when we are in multi panel mode central panel is automatically gets selected
            showCenterPanel.isOn = true
            
            // we also need to allow for multiple segments to be selected
            lhsMultiSelect.allowsMultipleSelection = true
            rhsMultiSelect.allowsMultipleSelection = true
        }
    }
    
    @IBAction
    private func showOrHideEmptyView(_ sender: UISwitch) {
        if sender.isOn {
            // show the empty view
            panelView.showEmptyState()
        } else {
            // hide the empty state
            panelView.hideEmptyState()
        }
    }
    
    @IBAction
    private func showCentralPanel(_ sender: UISwitch) {
        // we can only take this action in single panel mode
        if panelView.configuration.panelMode == .single {
            if sender.isOn {
                // show central panel
                panelView.show(index: 0)
                lhsMultiSelect.selectAllSegments(false)
                rhsMultiSelect.selectAllSegments(false)
            } else {
                // user wants to hide the central panel
                // but it is not a valid action
                // if you want to hide the central panel in single panel mode
                // you should call panelView.showEmptyState() instead
                showOneActionAlert(title: "Invalid Action",
                                   message: "In single panel mode hiding the central panel is not a valid action.")
                sender.isOn = true
            }
        } else {
            // in multi panel mode
            if sender.isOn {
                // it is possible that central panel is hidden
                // after switching from single panel earlier
                panelView.show(index: 0)
            } else {
                // in multi panel mode, we cannot hide central panel
                sender.isOn = true
                
                showOneActionAlert(title: "Invalid Action", message: "In multi panel mode the central panel cannot be hidden.")
                // showEmptyView.isOn = true
                // panelView.showEmptyState()
            }
        }
    }
    
    private func addLabel(to vc: UIViewController, labelText: String) {
        let centerViewIndicator = UILabel()
        centerViewIndicator.translatesAutoresizingMaskIntoConstraints = false
        centerViewIndicator.text = labelText
        centerViewIndicator.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        vc.view.addSubview(centerViewIndicator)
        NSLayoutConstraint.activate([
            centerViewIndicator.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            centerViewIndicator.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
        ])
    }
    
    private func randomSystemColor() -> UIColor {
      let systemColors: [UIColor] = [
        .systemRed,
        .systemGreen,
        .systemBlue,
        .systemOrange,
        .systemYellow,
        .systemPink,
        .systemPurple,
        .systemGray,
        .systemBrown,
        .systemCyan,
        .systemIndigo,
        .systemMint,
        .systemTeal,
        // .black
      ]
      
      let randomIndex = Int.random(in: 0..<systemColors.count)
      return systemColors[randomIndex]
    }
    
    
    
    /// adds a child view controller and makes it full screen
    private func addPanelViewAsChildView(_ panelView: PanelView) {
        guard panelView.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(panelView)
        view.insertSubview(panelView.view, belowSubview: buttonGroupContainer)
        
        panelView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: panelView.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: panelView.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: panelView.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: panelView.view.bottomAnchor)
        ])
        
        panelView.didMove(toParent: self)
    }
}

extension ViewController: PanelViewDelegate {
    func didChangeSize(panelView: PanelView, changes: ScreenSizeChanges) {
        if changes.contains(.horizontalSizeChangedFromRegularToCompact) ||
            changes.contains(.verticalSizeChangedFromCompactToRegular) {
            //panelView.combineAll()
        }
    }
}

extension ViewController: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        func showOrHidePanel(panelIndex: Int, panelLabel: String) {
            if value {
                // show a new panel with a new view controller
                let aNewVC = UIViewController()
                aNewVC.navigationController?.setNavigationBarHidden(true, animated: false)
                if panelIndex == 0 {
                    aNewVC.view.backgroundColor = .systemBackground
                    addLabel(to: aNewVC, labelText: "Main")
                } else {
                    aNewVC.view.backgroundColor = randomSystemColor() //.systemBackground
                    addLabel(to: aNewVC, labelText: panelLabel)
                }
                panelView.show(viewController: aNewVC, at: panelIndex)
            } else {
                // hide the panel
                panelView.hide(index: panelIndex)
            }
        }
        
        if multiSelectSegmentedControl == lhsMultiSelect {
            // we need to deselect buttons from the other controls if we are in a single panel mode
            if panelView.configuration.panelMode == .single {
                rhsMultiSelect.selectAllSegments(false)
            }
            
            // left hand side multi select controls are clicked
            if let titleForSegment = lhsMultiSelect.titleForSegment(at: index), let panelIndex = Int(titleForSegment) {
                showOrHidePanel(panelIndex: (panelIndex * -1), panelLabel: String(panelIndex * -1))
            }
        } else if multiSelectSegmentedControl == rhsMultiSelect {
            // we need to deselect buttons from the other controls if we are in a single panel mode
            if panelView.configuration.panelMode == .single {
                lhsMultiSelect.selectAllSegments(false)
            }
            
            // right hand side multi select controls are clicked
            if let titleForSegment = rhsMultiSelect.titleForSegment(at: index), let panelIndex = Int(titleForSegment) {
                showOrHidePanel(panelIndex: panelIndex, panelLabel: titleForSegment)
            }
        }
        
        if panelView.configuration.panelMode == .single {
            // in single panel mode central panel can be hidden
            showCenterPanel.isOn = false
        }
    }
}


extension PanelIndex {
    public static var main: PanelIndex {
        return PanelIndex(index: 0, tag: "main")
    }
}
