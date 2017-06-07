//
//  CalculatorsViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing
import RealmSwift

class CalculatorsViewController: UIViewController {

    @IBOutlet weak var gpaRing: UICircularProgressRingView!
    @IBOutlet weak var lastCalculationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up the UI
        
        self.gpaRing.font = UIFont.systemFont(ofSize: self.gpaRing.frame.width/7.0)

        
        // Set the progress ring and label
        let attrs = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.mainText.withAlphaComponent(0.6)]
        let savedCalculations = try! Realm().objects(GPACalculation.self).sorted(byKeyPath: "date", ascending: true)
        
        if let lastCalculation = savedCalculations.last {
            // Set max value of progress ring depending on weighted or not
            let max: CGFloat = lastCalculation.isWeighted ? 5.0 : 4.0
            gpaRing.maxValue = max
            gpaRing.setProgress(value: 0, animationDuration: 0)
            gpaRing.setProgress(value: CGFloat(lastCalculation.calculatedGpa), animationDuration: 0)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            lastCalculationLabel.attributedText = NSAttributedString(string: "Last calculated on: \(formatter.string(from: lastCalculation.date))", attributes: attrs)
        } else {
            gpaRing.setProgress(value: 0.0, animationDuration: 0)
            lastCalculationLabel.attributedText = NSAttributedString(string: "Never calculated, calculate now", attributes: attrs)
        }
    }

}