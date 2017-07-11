//
//  PreviousClassDetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/10/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import CoreMotion

class PreviousClassDetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeHolderView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    public var className: String? = nil
    public var gradeString: String? = nil
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.background
        // UI setup
        bgView.layer.cornerRadius = 10
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowRadius = 10.0
        
        gradeHolderView.layer.shadowColor = UIColor.black.cgColor
        gradeHolderView.layer.shadowOffset = CGSize(width: 0, height: 0)
        gradeHolderView.layer.shadowOpacity = 0.8
        gradeHolderView.layer.shadowRadius = 8.0
        
        button.layer.cornerRadius = 10
        button.layer.backgroundColor = UIColor.highlight.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = className
        gradeLabel.text = gradeString
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Set full circle for radius
        gradeHolderView.layer.cornerRadius = gradeHolderView.frame.height / 2
    }
    
    // MARK: Helpers
    
    /// Hides all the views, this will be done if a class is deleted, and the application is in split screen mode
    public func hideViews() {
        self.title = nil
        
        bgView.isHidden = true
        titleLabel.isHidden = true
        gradeHolderView.isHidden = true
        gradeLabel.isHidden = true
        button.isHidden = true
    }
    
    // MARK: Actions
    
    @IBAction func buttonWasTapped(_ sender: UIButton) {
        button.animateWithPulse(withDuration: 0.2) {
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            guard let tabBar = window?.rootViewController as? UITabBarController,
                tabBar.childViewControllers.count > 1,
                let calcsVC = tabBar.childViewControllers[1] as? CalculatorsViewController else {
                    
                    print("WARNING: Tried to find ClassesTableViewController but was not able.")
                    return
            }
            
            // Perform segue and show gpa calculator
            tabBar.selectedIndex = 1
            calcsVC.performSegue(withIdentifier: "presentGPACalculator", sender: nil)
        }
    }
    
}
