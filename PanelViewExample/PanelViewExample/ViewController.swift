//
//  ViewController.swift
//  PanelViewExample
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit
import PanelView

class ViewController: UIViewController {
    
    @IBOutlet private var buttonGroup: UIStackView!
    @IBOutlet private var leadingPlusButton: UIButton!
    @IBOutlet private var trailingPlusButton: UIButton!
    @IBOutlet private var leadingMinusButton: UIButton!
    @IBOutlet private var trailingMinusButton: UIButton!
    
    var panelIndexes = [Int]()
    
    private var panelView: PanelViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addPanelView()
        leadingPlusButton.setTitle("", for: .normal)
        trailingPlusButton.setTitle("", for: .normal)
        leadingMinusButton.setTitle("", for: .normal)
        trailingMinusButton.setTitle("", for: .normal)
    }

    private func addPanelView() {
        panelView = PanelViewController()
        
        var customConfig = PanelViewConfiguration()
        
        customConfig.orientation = .vertical
        
        let emptyStackView = UIStackView()
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.spacing = 8
        
        // image for the empty state
        let emptyViewImage = UIImageView(image: UIImage(systemName: "macpro.gen3"))
        NSLayoutConstraint.activate([
            emptyViewImage.widthAnchor.constraint(equalToConstant: 60),
            emptyViewImage.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        emptyStackView.addArrangedSubview(emptyViewImage)
        
        
        let customLabel = UILabel()
        customLabel.text = "Bonanza"
        customLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        emptyStackView.addArrangedSubview(customLabel)
        
        
        customConfig.emptyStateView = emptyStackView
        
        panelView.configuration = customConfig
        
        
        for index in -10...11 {
            if index == 0 {
                continue
            }
            let onTheFlyPanelIndex = PanelIndex(index: index)
            panelView.minimumWidth(200, for: onTheFlyPanelIndex)
            panelView.maximumWidth(600, for: onTheFlyPanelIndex)
            panelView.preferredWidthFraction(0.225, at: index)
        }
        
        
        addFullScreen(childViewController: panelView)
    }
       
    /// adds a child view controller and makes it full screen
    public func addFullScreen(childViewController child: UIViewController) {
        guard child.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(child)
        view.insertSubview(child.view, belowSubview: buttonGroup)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: child.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ])
        
        child.didMove(toParent: self)
    }
    
    @IBAction
    private func didClickOnAdd(_ sender: UIButton) {
        if sender.tag == -1 {
            if panelIndexes.contains(0) {
                let leftSideVC = UIViewController()
                leftSideVC.view.backgroundColor = randomSystemColor()
                
                
                let newIndex = (panelIndexes.min() ?? 0) - 1
                panelIndexes.append(newIndex)
                panelView.show(viewController: leftSideVC, at: newIndex)
            } else {
                panelIndexes.append(0)
                // add the main panel
                let initial = UIViewController()
                initial.view.backgroundColor = .systemBackground
                
                let centerViewIndicator = UILabel()
                centerViewIndicator.translatesAutoresizingMaskIntoConstraints = false
                centerViewIndicator.text = "Main"
                centerViewIndicator.font = UIFont.preferredFont(forTextStyle: .largeTitle)
                
                initial.view.addSubview(centerViewIndicator)
                NSLayoutConstraint.activate([
                    centerViewIndicator.centerXAnchor.constraint(equalTo: initial.view.centerXAnchor),
                    centerViewIndicator.centerYAnchor.constraint(equalTo: initial.view.centerYAnchor),
                ])
                
                panelView.show(viewController: initial, for: .centerPanel)
            }
        } else {
            if panelIndexes.contains(0) {
                let rightSideVC = UIViewController()
                rightSideVC.view.backgroundColor = randomSystemColor()
                
                
                let newIndex = (panelIndexes.max() ?? 0) + 1
                panelIndexes.append(newIndex)
                panelView.show(viewController: rightSideVC, at: newIndex)
            } else {
                panelIndexes.append(0)
                // add the main panel
                let initial = UIViewController()
                initial.view.backgroundColor = .systemBackground
                
                let centerViewIndicator = UILabel()
                centerViewIndicator.translatesAutoresizingMaskIntoConstraints = false
                centerViewIndicator.text = "Main"
                centerViewIndicator.font = UIFont.preferredFont(forTextStyle: .largeTitle)
                
                initial.view.addSubview(centerViewIndicator)
                NSLayoutConstraint.activate([
                    centerViewIndicator.centerXAnchor.constraint(equalTo: initial.view.centerXAnchor),
                    centerViewIndicator.centerYAnchor.constraint(equalTo: initial.view.centerYAnchor),
                ])
                
                panelView.show(viewController: initial, for: .centerPanel)
            }
        }
    }
    
    @IBAction
    private func didClickOnRemove(_ sender: UIButton) {
        if sender.tag == -1 {
            if let indexToRemove = panelIndexes.min() {
                panelView.hide(index: indexToRemove)
                panelIndexes.sort()
                panelIndexes.remove(at: 0)
            }
        } else {
            if let indexToRemove = panelIndexes.max() {
                panelView.hide(index: indexToRemove)
                panelIndexes.sort()
                panelIndexes.remove(at: (panelIndexes.endIndex - 1))
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
        .black
      ]
      
      let randomIndex = Int.random(in: 0..<systemColors.count)
      return systemColors[randomIndex]
    }
}

