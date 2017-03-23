//
//  UIAddGPAView.swift
//  GradePoint
//
//  Created by Luis Padron on 3/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

enum UIAddGPAViewState: Int {
    case add = 1
    case delete = 2
}

class UIAddGPAView: UIView {
    // MARK: Properties
    
    // Button properties
    var circleSpacing: CGFloat = 30
    var buttonRadius: CGFloat = 17
    var addButtonOffSet: CGFloat = 1
    var addColor: UIColor = .palePurple
    var deleteColor: UIColor = .sunsetOrange
    var plusColor: UIColor = UIColor.white
    private lazy var circleLayer = CAShapeLayer()
    private lazy var plusButtonLayer = CAShapeLayer()
    private var buttonRect: CGRect?
    
    // Animation properties
    var animationDuration: TimeInterval = 0.3
    var isAnimating: Bool = false
    var state: UIAddGPAViewState = .add
    
    // View properties
    var fontSize: CGFloat = 18
    
    /// Delegate
    weak var delegate: UIAddGPAViewDelegate?
    
    // MARK: Initializers/Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkBg
        self.drawButton()
        self.addFields()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkBg
        self.drawButton()
        self.addFields()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update frames for fields
        let labelWidth = self.bounds.width - (self.circleLayer.bounds.maxX + 50)
        let labelFrame = CGRect(x: self.circleLayer.bounds.maxX + 50, y: self.bounds.minY, width: labelWidth, height: self.bounds.height)
        self.addRubricLabel.frame = labelFrame
        
        let width = self.bounds.width - (self.circleLayer.bounds.maxX + 50) - 50 - self.circleLayer.bounds.width
        let nameFieldFrame = CGRect(x: self.circleLayer.bounds.maxX + 20, y: self.bounds.minY, width: width*0.5, height: self.bounds.height)
        let gradeFieldFrame = CGRect(x: nameFieldFrame.maxX + 20, y: self.bounds.minY, width: width*0.25, height: self.bounds.height)
        let creditFieldFrame = CGRect(x: gradeFieldFrame.maxX + 20, y: self.bounds.minY, width: width*0.25, height: self.bounds.height)
        
        self.nameField.frame = nameFieldFrame
        self.gradeField.frame = gradeFieldFrame
        self.creditsField.frame = creditFieldFrame
    }
    
    // MARK: Drawing
    
    private func drawButton() {
        let circle = UIBezierPath(arcCenter: CGPoint(x: bounds.minX + circleSpacing, y: bounds.midY), radius: buttonRadius,
                                  startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2),
                                  clockwise: true)
        
        circleLayer = CAShapeLayer()
        circleLayer.path = circle.cgPath
        circleLayer.strokeColor = nil
        circleLayer.fillColor = addColor.cgColor
        circleLayer.lineWidth = 1.0
        circleLayer.frame = circle.bounds
        circleLayer.bounds = circle.bounds
        self.layer.addSublayer(circleLayer)
    
        
        // Draw the plus button
        let circleBounds = circle.bounds
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(circleBounds.width, circleBounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = plusHeight
        plusPath.lineCapStyle = .square
        
        plusPath.move(to: CGPoint(x: circleBounds.midX - plusWidth/2 + 0.5 + addButtonOffSet, y: bounds.midY + 0.5))
        plusPath.addLine(to: CGPoint(x: circleBounds.midX + plusWidth/2 + 0.5 - addButtonOffSet, y: bounds.midY + 0.5))
        
        plusPath.move(to: CGPoint(x: circleBounds.midX + 0.5, y: circleBounds.midY - plusWidth/2 + 0.5 + addButtonOffSet))
        plusPath.addLine(to: CGPoint(x: circleBounds.midX + 0.5, y: circleBounds.midY + plusWidth/2 + 0.5 - addButtonOffSet))
        
        plusButtonLayer.path = plusPath.cgPath
        plusButtonLayer.strokeColor = plusColor.cgColor
        plusButtonLayer.fillColor = nil
        plusButtonLayer.lineWidth = plusHeight
        plusButtonLayer.lineJoin = kCALineCapSquare
        plusButtonLayer.frame = plusPath.bounds
        plusButtonLayer.bounds = plusPath.bounds
        
        self.layer.addSublayer(plusButtonLayer)
        
        buttonRect = circleBounds
        
        // Add a gesture recognizer for the button
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnButton(recognizer:)))
        self.addGestureRecognizer(gesture)
    }
    
    private func addFields() {
        self.addSubview(addRubricLabel)
        self.addSubview(nameField)
        self.addSubview(gradeField)
        self.addSubview(creditsField)
    }
    
    // MARK: Actions
    
    @objc private func tappedOnButton(recognizer: UITapGestureRecognizer) {
        guard let buttonRect = buttonRect else {
            print("Button rect not found when tapped on button")
            return
        }
        
        let point = recognizer.location(in: self)
        
        if buttonRect.contains(point) || (addRubricLabel.frame.contains(point) && !addRubricLabel.isHidden) {
            // And animate the view
            if !self.isAnimating {
                self.animateViews(completion: {
                    // Notify delegate
                    self.delegate?.addButtonTouched(forView: self)
                })
            }
        }
    }

    // MARK: Animation
    
    /// Animates the views to the proper state
    func animateViews(completion: (() -> Void)? = nil) {
        isAnimating = true
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.duration = animationDuration
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = kCAFillModeForwards
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.duration = animationDuration
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = kCAFillModeForwards
        colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Switch on the current state of the view, whether adding or removing
        switch state {
        case .add:
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = CGFloat(45).toRads
            colorAnimation.fromValue = addColor.cgColor
            colorAnimation.toValue = deleteColor.cgColor
            // Add the animation
            plusButtonLayer.add(rotationAnimation, forKey: "rotationAnimation")
            circleLayer.add(colorAnimation, forKey: "colorAnimation")
            animateFieldsToDelete {
                // Make name first responder
                self.nameField.becomeFirstResponder()
                // Toggle to the state we will animate to
                self.state = .delete
                self.isAnimating = false
                completion?()
            }
        case .delete:
            rotationAnimation.fromValue = CGFloat(45).toRads
            rotationAnimation.toValue = 0.0
            colorAnimation.fromValue = deleteColor.cgColor
            colorAnimation.toValue = addColor.cgColor
            // Add the animation
            plusButtonLayer.add(rotationAnimation, forKey: "rotationAnimation")
            circleLayer.add(colorAnimation, forKey: "colorAnimation")
            animateFieldsToAdd {
                // Toggle to the state we will animate to
                self.endEditing(true)
                self.state = .add
                self.isAnimating = false
                completion?()
            }
        }
    }
    
    private func animateFieldsToAdd(completion: @escaping (() -> Void)) {
        // Prepare for animation
        addRubricLabel.isHidden = false
        addRubricLabel.layer.opacity = 0.0
        nameField.layer.opacity = 1.0
        gradeField.layer.opacity = 1.0
        creditsField.layer.opacity = 1.0

        
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                self.addRubricLabel.layer.opacity = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                self.nameField.layer.opacity = 0.0
                self.gradeField.layer.opacity = 0.0
                self.creditsField.layer.opacity = 0.0
            })
        }) { _ in
            self.nameField.isHidden = true
            self.gradeField.isHidden = true
            self.creditsField.isHidden = true
            completion()
        }
    }

    private func animateFieldsToDelete(completion: @escaping (() -> Void)) {
        // Prepare for animation
        addRubricLabel.layer.opacity = 1.0
        nameField.layer.opacity = 0.0
        gradeField.layer.opacity = 0.0
        creditsField.layer.opacity = 0.0
        nameField.isHidden = false
        gradeField.isHidden = false
        creditsField.isHidden = false
        
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [], animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: { 
                self.addRubricLabel.layer.opacity = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                self.nameField.layer.opacity = 1.0
                self.gradeField.layer.opacity = 1.0
                self.creditsField.layer.opacity = 1.0
            })
        }) { _ in
            self.addRubricLabel.isHidden = true
            completion()
        }
    }
    

    // MARK: Views
    
    lazy var addRubricLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a class"
        label.textColor = UIColor.mutedText
        label.font = UIFont.systemFont(ofSize: self.fontSize)
        return label
    }()
    
    /// The name field for the GPA View
    lazy var nameField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text, configuration: TextConfiguration())
        field.placeholder = "Name"
        field.titleText = "Name"
        field.titleTextColor = .palePurple
        field.textColor = .lightText
        field.borderStyle = .none
        field.tintColor = .palePurple
        field.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.returnKeyType = .next
        field.delegate = self
        field.isHidden = true
        field.font = UIFont.systemFont(ofSize: self.fontSize)
        
        return field
    }()
    
    lazy var gradeField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text, configuration: TextConfiguration(maxCharacters: 2))
        field.placeholder = "Grade"
        field.titleText = "Grade"
        field.titleTextColor = .palePurple
        field.textColor = .lightText
        field.borderStyle = .none
        field.tintColor = .palePurple
        field.attributedPlaceholder = NSAttributedString(string: "Grade", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.returnKeyType = .next
        field.delegate = self
        field.isHidden = true
        field.font = UIFont.systemFont(ofSize: self.fontSize)
        
        return field
    }()
    
    lazy var creditsField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .number,
                                              configuration: NumberConfiguration(allowsSignedNumbers: false, range: 1...99))
        field.placeholder = "Credits"
        field.titleText = "Credits"
        field.titleTextColor = .palePurple
        field.textColor = .lightText
        field.borderStyle = .none
        field.tintColor = .palePurple
        field.keyboardType = .numbersAndPunctuation
        field.attributedPlaceholder = NSAttributedString(string: "Credits", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.returnKeyType = .done
        field.delegate = self
        field.isHidden = true
        field.font = UIFont.systemFont(ofSize: self.fontSize)
        
        return field
    }()
}


// MARK: Textfield Delegation

extension UIAddGPAView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch fields when pressing next or done button

        switch textField {
        case nameField:
            nameField.resignFirstResponder()
            gradeField.becomeFirstResponder()
        case gradeField:
            gradeField.resignFirstResponder()
            creditsField.becomeFirstResponder()
        case creditsField:
            creditsField.resignFirstResponder()
        default:
            return true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Dont allow editing in the gradeField as this really inteded to be used as a picker
        if textField === self.gradeField { return false }
        // Check if text should be allowed
        guard let field = textField as? UIFloatingPromptTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}
