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
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var sequence: [String] = []
    
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
            var desc = " "
            for item in sequence {
                desc += " "
                if let operation = operations[item] {
                    switch operation {
                    case .Constant:
                        desc += item
                    case .UnaryOperation:
                        desc = "\(item)(\(desc))"
                    case .BinaryOperation:
                        desc += item
                    case .Equals:
                        break
                    }
                }
                else {
                    desc += item
                }
            }
            return desc
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
        "=": Operation.Equals
    ]
    
    func setOperand(_ operand: Double) {
        if !isPartialResult {
            sequence.removeAll()
        }
        sequence.append(String(operand))
        accumulator = operand
    }
    
    func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constant):
                setOperand(constant)
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
        sequence.append(symbol)
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
}
