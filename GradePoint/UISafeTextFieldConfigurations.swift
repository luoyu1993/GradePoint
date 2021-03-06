//
//  UISafeTextFieldConfigurations.swift
//  GradePoint
//
//  Created by Luis Padron on 2/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

/// Configuration Options for the textfield
public protocol FieldConfiguration {}

/// Configuration for a number textfield
public struct NumberConfiguration: FieldConfiguration {
    public var range: ClosedRange<Double>?
    public let allowsSignedNumbers: Bool
    public var allowsFloating: Bool = true
    
    init(allowsSignedNumbers: Bool = true) {
        self.allowsSignedNumbers = allowsSignedNumbers
    }
    
    init(allowsSignedNumbers: Bool = true, range: ClosedRange<Double>) {
        self.allowsSignedNumbers = allowsSignedNumbers
        self.range = range
    }
}

/// Configuration for a percent textfield
public struct PercentConfiguration: FieldConfiguration {
    public let allowsOver100: Bool
    public let allowsFloatingPoint: Bool
    public var allowsZeroPercent = true
    
    init(allowsOver100: Bool, allowsFloatingPoint: Bool) {
        self.allowsOver100 = allowsOver100
        self.allowsFloatingPoint = allowsFloatingPoint
    }
}

/// Configuration for text field
public struct TextConfiguration: FieldConfiguration {
    public let maxCharacters: Int
    
    init(maxCharacters: Int = Int.max) {
        self.maxCharacters = maxCharacters
    }
}
