//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 12/22/16.
//  Copyright © 2016 Vladimir Burmistrovich. All rights reserved.
//

import Foundation

func factorial(_ num: UInt64) -> UInt64 {
    if num == 0 {
        return 1
    }
    else {
        return num * factorial(num - 1)
    }
}

class CalculatorBrain {
    
    private enum Operation {
        case Constant(Double)
        case NullaryOperation(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var internalDescription = " "
    private var pendingOperand: String?
    private var describePendingOperand = false
    private var internalProgram = [Any]()
    
    typealias PropertyList = Any
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            performOperation("C")
            if let arrayOfOps = newValue as? [Any] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    }
                    else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            if describePendingOperand && pendingOperand != nil {
                return internalDescription + pendingOperand!
            }
            else {
                return internalDescription
            }
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "±": Operation.UnaryOperation({-$0}),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "x²": Operation.UnaryOperation({$0 * $0}),
        "x³": Operation.UnaryOperation({$0 * $0 * $0}),
        "x!": Operation.UnaryOperation({Double(factorial(UInt64($0)))}),
        "×": Operation.BinaryOperation(*),
        "÷": Operation.BinaryOperation(/),
        "+": Operation.BinaryOperation(+),
        "−": Operation.BinaryOperation(-),
        "rand": Operation.NullaryOperation(drand48),
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    func setOperand(_ operand: Double) {
        if !isPartialResult {
            internalDescription = ""
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        pendingOperand = formatter.string(from: NSNumber(value: operand))
        describePendingOperand = false
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constant):
                if !isPartialResult {
                    internalDescription = ""
                }
                pendingOperand = symbol
                describePendingOperand = true
                accumulator = constant
            case .UnaryOperation(let function):
                if let pendingOp = pendingOperand {
                    internalDescription += "\(symbol)(\(pendingOp))"
                    pendingOperand = nil
                }
                else {
                    internalDescription = "\(symbol)(\(internalDescription))"
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                if pendingOperand != nil {
                    internalDescription += pendingOperand!
                }
                internalDescription += " \(symbol) "
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .NullaryOperation(let function):
                if !isPartialResult {
                    internalDescription = ""
                }
                pendingOperand = symbol
                describePendingOperand = true
                accumulator = function()
            case .Equals:
                if pendingOperand != nil {
                    internalDescription += pendingOperand!
                    pendingOperand = nil
                }
                executePendingBinaryOperation()
            case .Clear:
                accumulator = 0.0
                pending = nil
                internalDescription = ""
                pendingOperand = nil
                describePendingOperand = false
                internalProgram.removeAll()
            }
            
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
}
