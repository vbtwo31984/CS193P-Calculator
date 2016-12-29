//
//  ViewController.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 12/22/16.
//  Copyright © 2016 Vladimir Burmistrovich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    private var savedProgram: CalculatorBrain.PropertyList?
    
    private var displayValue: Double? {
        get {
            return Double(display.text!)!
        }
        set {
            if newValue == nil {
                display.text = " "
            }
            else {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 6
                display.text = formatter.string(from: NSNumber(value: newValue!))
            }
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." {
            if display.text!.range(of: digit) == nil {
                display.text = display.text! + digit
            }
        }
        else {
            if userIsInTheMiddleOfTyping {
                display.text = display.text! + digit
            }
            else {
                display.text = digit
            }
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private func setDescriptionDisplay() {
        var descriptionText = brain.description
        if brain.isPartialResult {
            descriptionText += "..."
        }
        else {
            descriptionText += "="
        }
        descriptionLabel.text = " " + descriptionText
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let displayValue = displayValue {
                brain.setOperand(displayValue)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
            
        }
        displayValue = brain.result
        setDescriptionDisplay()
    }
    
    @IBAction func backSpace() {
        if userIsInTheMiddleOfTyping {
            let lastIndex = display.text!.index(before: display.text!.endIndex)
            var newDisplayValue = display.text!.substring(to: lastIndex)
            if newDisplayValue.characters.count == 0 {
                newDisplayValue = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = newDisplayValue
        }
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            setDescriptionDisplay()
        }
    }
    
}

