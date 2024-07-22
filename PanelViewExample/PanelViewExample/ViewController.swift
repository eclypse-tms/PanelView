//
//  ViewController.swift
//  PanelViewExample
//
//  Created by eclypse on 7/12/24.
//

import UIKit
import PanelView
import Combine

class ViewController: UIViewController {
    
    @IBOutlet private var buttonGroup: UIStackView!
    @IBOutlet private var leadingPlusButton: UIButton!
    @IBOutlet private var trailingPlusButton: UIButton!
    @IBOutlet private var leadingMinusButton: UIButton!
    @IBOutlet private var trailingMinusButton: UIButton!
    @IBOutlet private var changeOrientationButton: UIButton!
    
    var panelIndexes = [Int]()
    
    private var cancellables = Set<AnyCancellable>()
    private var panelView: PanelView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addPanelView()
        // configureBindings()
        leadingPlusButton.setTitle("", for: .normal)
        trailingPlusButton.setTitle("", for: .normal)
        leadingMinusButton.setTitle("", for: .normal)
        trailingMinusButton.setTitle("", for: .normal)
        changeOrientationButton.setTitle("", for: .normal)
        
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
        customConfig.interPanelSpacing = 2
        
        customConfig.emptyStateView = configureEmptyView()
        
        panelView.configuration = customConfig
        
        
        for index in -panelView.configuration.numberOfPanelsToPrime...panelView.configuration.numberOfPanelsToPrime {
            if index == 0 {
                continue
            }
            let onTheFlyPanelIndex = Panel(index: index)
            panelView.minimumWidth(100, for: onTheFlyPanelIndex)
            panelView.maximumWidth(600, for: onTheFlyPanelIndex)
            panelView.preferredWidthFraction(0.1, at: index)
        }
        
        
        addPanelViewAsChildView(panelView)
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
    private func didClickOnAdd(_ sender: UIButton) {
        func addLabel(to vc: UIViewController, labelText: String) {
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
        
        if sender.tag == -1 {
            if panelIndexes.contains(0) {
                let leftSideVC = UIViewController()
                leftSideVC.navigationController?.setNavigationBarHidden(true, animated: false)
                leftSideVC.view.backgroundColor = randomSystemColor() //.systemBackground
                
                let newIndex = (panelIndexes.min() ?? 0) - 1
                addLabel(to: leftSideVC, labelText: String(newIndex))
                
                panelIndexes.append(newIndex)
                panelView.show(viewController: leftSideVC, at: newIndex)
            } else {
                panelIndexes.append(0)
                // add the main panel
                let initial = UIViewController()
                initial.navigationController?.setNavigationBarHidden(true, animated: false)
                initial.view.backgroundColor = .systemBackground
                
                addLabel(to: initial, labelText: "Main")
                
                panelView.show(viewController: initial, for: .main)
            }
        } else {
            if panelIndexes.contains(0) {
                let rightSideVC = UIViewController()
                rightSideVC.navigationController?.setNavigationBarHidden(true, animated: false)
                rightSideVC.view.backgroundColor = randomSystemColor() // .systemBackground
                
                let newIndex = (panelIndexes.max() ?? 0) + 1
                addLabel(to: rightSideVC, labelText: String(newIndex))
                
                panelIndexes.append(newIndex)
                panelView.show(viewController: rightSideVC, at: newIndex)
            } else {
                panelIndexes.append(0)
                // add the main panel
                let initial = UIViewController()
                initial.navigationController?.setNavigationBarHidden(true, animated: false)
                initial.view.backgroundColor = .systemBackground
                
                addLabel(to: initial, labelText: "Main")
                
                panelView.show(viewController: initial, for: .center)
            }
        }
    }
    
    @IBAction
    private func didClickOnRemove(_ sender: UIButton) {
        guard panelIndexes.count > 0 else { return }
        if panelIndexes.count == 1 {
            // there is only one panel (presumably center panel)
            panelView.hide(index: 0)
            panelIndexes.remove(at: 0)
        } else {
            if sender.tag == -1 {
                if let indexToRemove = panelIndexes.min() {
                    if indexToRemove < 0 {
                        // this button can only remove left panels
                        panelView.hide(index: indexToRemove)
                        panelIndexes.sort()
                        panelIndexes.remove(at: 0)
                    }
                }
            } else {
                if let indexToRemove = panelIndexes.max() {
                    if indexToRemove > 0 {
                        // this button can only remove right panels
                        panelView.hide(index: indexToRemove)
                        panelIndexes.sort()
                        panelIndexes.remove(at: (panelIndexes.endIndex - 1))
                    }
                }
            }
        }
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
    
    @IBAction
    private func didChangeOrientation(_ sender: UIButton) {
        if panelView.configuration.orientation == .horizontal {
            panelView.configuration.orientation = .vertical
        } else {
            panelView.configuration.orientation = .horizontal
        }
    }
    
    /// adds a child view controller and makes it full screen
    private func addPanelViewAsChildView(_ panelView: PanelView) {
        guard panelView.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(panelView)
        view.insertSubview(panelView.view, belowSubview: buttonGroup)
        
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


extension Panel {
    public static var main: Panel {
        return Panel(index: 0, tag: "main")
    }
}
