//
//  ExamGradePredictionViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ExamGradePredictionViewController: UIViewController {

    // MARK: Properties
    
    // Buttons
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    // Fields
    @IBOutlet weak var currentGradeField: UISafeTextField!
    @IBOutlet weak var desiredGradeField: UISafeTextField!
    @IBOutlet weak var examWorthField: UISafeTextField!
    // Views
    @IBOutlet weak var needGetLabel: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var isInitialCalculation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Setup
        self.exitButton.tintColor = .white
        
        let percentConfig = PercentConfiguration(allowsOver100: false, allowsFloatingPoint: true)
        let placeHolderAttrs = [NSForegroundColorAttributeName: UIColor.mutedText, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        self.currentGradeField.configuration = percentConfig
        self.currentGradeField.fieldType = .percent
        self.currentGradeField.attributedPlaceholder = NSAttributedString(string: "Example: 86%", attributes: placeHolderAttrs)
        self.currentGradeField.textColor = UIColor.white
        
        self.desiredGradeField.configuration = percentConfig
        self.desiredGradeField.fieldType = .percent
        self.desiredGradeField.attributedPlaceholder = NSAttributedString(string: "Example: 90%", attributes: placeHolderAttrs)
        self.desiredGradeField.textColor = UIColor.white
        
        self.examWorthField.configuration = percentConfig
        self.examWorthField.fieldType = .percent
        self.examWorthField.attributedPlaceholder = NSAttributedString(string: "Example: 15%", attributes: placeHolderAttrs)
        self.examWorthField.textColor = UIColor.white
        
        self.calculateButton.setTitleColor(UIColor.mutedText, for: .disabled)
        self.calculateButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onExitButtonTap(_ sender: UIButton) {
        // Quickly animate the exit button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.exitButton.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func onCalculateButtonTap(_ sender: UIButton) {
        if isInitialCalculation { animateViews() }
        else { calculateScore() }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UISafeTextField) {
        self.calculateButton.isEnabled = !self.currentGradeField.safeText.isEmpty && !self.desiredGradeField.safeText.isEmpty && !self.examWorthField.safeText.isEmpty
    }
    
    // MARK: Helper Methods
    
    func animateViews() {
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [], animations: { 
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: { 
                self.needGetLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: { 
                self.progressRing.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: { 
                self.messageLabel.alpha = 1.0
            })
            
        }) { (finished) in
            if finished { self.calculateScore() }
        }
    }
    
    func calculateScore() {
        if self.isInitialCalculation { self.isInitialCalculation = false }
        guard let currentGrade = Double(currentGradeField.safeText), let desiredGrade = Double(desiredGradeField.safeText),
        let examWorth = Double(examWorthField.safeText) else {
            self.progressRing.setProgress(value: 0.0, animationDuration: 0)
            return
        }
        
        let gradeNeeded = CGFloat((100.0 * desiredGrade - (100.0 - examWorth) * currentGrade)/examWorth)
        
        self.progressRing.setProgress(value: gradeNeeded, animationDuration: 1.5) { [unowned self] in
            self.messageLabel.text = ScoreMessage.createMessage(forScore: gradeNeeded)
        }
    }
    
    func createMessage(forScore score: CGFloat) -> String {
        
        return ""
    }
}

// MARK: TextField Delegation
extension ExamGradePredictionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return false }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}

// MARK: Messages Struct
struct ScoreMessage {
    
    private static var easyMessages = ["Thats easy, nice job!", "Wow, you easily got this!",
                                       "Too easy...", "Does 2 + 2 = 4?\nThats how hard you need to try."]
    
    private static var mediumMessage = ["Not too bad, study a bit", "Meh, I've seen harder.\nYou got this!",
                                        "Learn some Swift while studying, you should be okay!"]
    
    private static var hardMessage = ["Dang! Goodluck", "You can do it, I believe in you\nSort of.",
                                      "Hmmm... Maybe you can do it?", "Get to studying now!\nWhat are you waiting for?"]
    
    private static var extremelyHardMessage = ["Ok I don't know about this one, but goodluck!",
                                               "Is this even possible?", "Beg for extra credit", "I'm so sorry..."]
    
    
    static func createMessage(forScore score: CGFloat) -> String {
        switch Int(score) {
        case 0...60: // Easy messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.easyMessages.count)
            return ScoreMessage.easyMessages[index]
        case 61...79: // Medium messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.mediumMessage.count)
            return ScoreMessage.mediumMessage[index]
        case 80...100: // Hard messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.hardMessage.count)
            return ScoreMessage.hardMessage[index]
        default: // Extremely hard messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.extremelyHardMessage.count)
            return ScoreMessage.extremelyHardMessage[index]
        }
    }
}