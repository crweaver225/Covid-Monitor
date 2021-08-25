//
//  CovidEvaluater.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/24/21.
//

import Foundation



class CovidEvaluator {
    
    private var positiveResultPredicted: Bool = false
    
    private var positveInfo: [String:Any] = [:]
    
    func evaluateSp02Pulse(data: [(SP02, Pulse)]) {
        for dataPoint in data {
            let model = Vitals()
            do {
                let prediction = try model.prediction(Oxy: dataPoint.0.data, Pulse: dataPoint.1.data)
                
                if prediction.classProbability[1] ?? 0.0 > 0.75 {
                    positiveResultPredicted = true
                    positveInfo["probability"] = prediction.classProbability[1] ?? 0.0
                    positveInfo["timestamp"] = Int(Date().timeIntervalSince1970)
                    print("Postive diagnosis for Covid: \(prediction.classProbability[1] ?? 0.0)")
                } else {
                    print("Negative diagnosis for Covid: \(prediction.classProbability[0] ?? 0.0)")
                }
            } catch { print("Model was not able to execute") }
        }
    }
    
    func positveResultsPredicted() -> Bool {
        return positiveResultPredicted
    }
    
    func returnMoreInfo() -> [String:Any] {
        return positveInfo
    }
}
