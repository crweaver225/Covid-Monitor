//
//  HealthData.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/24/21.
//

import Foundation
import HealthKit
import CoreML

struct SP02 {
    
    init(data: Double, starDate: Date, endDate: Date) {
        self.data = data
        self.startDate = starDate
        self.endDate = endDate
    }
    
    var data: Double
    var startDate: Date
    var endDate: Date
}

struct Pulse {
    
    init(data: Double, starDate: Date, endDate: Date) {
        self.data = data
        self.startDate = starDate
        self.endDate = endDate
    }
    
    func isWithin30Minutes(startDate: Date, endDate: Date) -> Bool {
        let startDateConverted = startDate.addingTimeInterval(TimeInterval(-1800))
        let endDateConverted = endDate.addingTimeInterval(TimeInterval(1800))
        
        if self.startDate > startDateConverted && self.endDate < endDateConverted {
            return true
        }

        return false
    }
    
    var data: Double
    var startDate: Date
    var endDate: Date
}

class HealthDataExtractor {
    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    var sp02Values: [SP02] = []
    var pulseValues: [Pulse] = []
    private var combinedDataPoints: [(SP02, Pulse)] = []
    
    let sP02Type: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
    var sP02Query: HKSampleQuery?
    
    func returnDataPoints() -> [(SP02, Pulse)] {
        return self.combinedDataPoints
    }
    
    
    func getPulseData(completionHandler: @escaping( _ finished: Bool) -> Void) {

            let calendar = NSCalendar.current
            let now = NSDate()
            let components = calendar.dateComponents([.year, .month, .day], from: now as Date)
            
            guard let startDate:NSDate = calendar.date(from: components) as NSDate? else { return }
            var dayComponent    = DateComponents()
            dayComponent.day    = 1
            let endDate:NSDate? = calendar.date(byAdding: dayComponent, to: startDate as Date) as NSDate?
            let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])

            let sortDescriptors = [
                                    NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                                  ]
            
            heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
                
                guard error == nil else { print("error"); return }
                
                self.printHeartRateInfo(results: results)
                self.parsePulseData(results: results)
                completionHandler(true)
            })
            
            health.execute(heartRateQuery!)
    }
    
    func getSp02(completionHandler: @escaping( _ finished: Bool) -> Void) {
        
        let calendar = NSCalendar.current
        let now = NSDate()
        let components = calendar.dateComponents([.year, .month, .day], from: now as Date)
        
        guard let startDate:NSDate = calendar.date(from: components) as NSDate? else { return }
        var dayComponent    = DateComponents()
        dayComponent.day    = 1
        let endDate:NSDate? = calendar.date(byAdding: dayComponent, to: startDate as Date) as NSDate?
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])
        
        
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]
        
        sP02Query = HKSampleQuery(sampleType: sP02Type, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            
            guard error == nil else { print("error"); return }
            
            self.parseSPO2Data(results: results)
            completionHandler(true)
        })
        health.execute(sP02Query!)
    }
    
    private func parseSPO2Data(results:[HKSample]?) {
        for (_, sample) in results!.enumerated() {
            guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
            let spo2DatPoint = SP02(data: currData.quantity.doubleValue(for: HKUnit.count()) * 100, starDate: currData.startDate, endDate: currData.endDate)
            sp02Values.append(spo2DatPoint)
        }
    }
    
    private func parsePulseData(results:[HKSample]?) {
        for (_, sample) in results!.enumerated() {
            guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
       
            let pulseDataPoint = Pulse(data: currData.quantity.doubleValue(for: heartRateUnit), starDate: currData.startDate, endDate: currData.endDate)
            pulseValues.append(pulseDataPoint)
        }
    }
    
    func findCorrespondingDataPoints() {
        for spo2 in self.sp02Values {
            var found = false
            for pulse in self.pulseValues {
                if pulse.isWithin30Minutes(startDate: spo2.startDate, endDate: spo2.endDate) && found == false {
                    
                    found = true
                    self.combinedDataPoints.append((spo2, pulse))
                }
            }
        }
        
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            let fakeSp02 = SP02(data: 87, starDate: Date().addingTimeInterval(TimeInterval(-800)), endDate: Date().addingTimeInterval(TimeInterval(-800)))
            let fakePulse = Pulse(data: 60, starDate: Date().addingTimeInterval(TimeInterval(-300)), endDate: Date().addingTimeInterval(TimeInterval(-300)))
            self.combinedDataPoints.append((fakeSp02, fakePulse))
        }
    }
    
    /*used only for testing, prints heart rate info */
    private func printHeartRateInfo(results:[HKSample]?)
    {
        for (_, sample) in results!.enumerated() {
            guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
            print("Heart Rate: \(currData.quantity.doubleValue(for: heartRateUnit))")
          //  print("quantityType: \(currData.quantityType)")
            print("Start Date: \(currData.startDate)")
            print("End Date: \(currData.endDate)")
           // print("Metadata: \(currData.metadata)")
           // print("UUID: \(currData.uuid)")
           // print("Source: \(currData.sourceRevision)")
           // print("Device: \(currData.device)")
           // print("---------------------------------\n")
        }
    }
    
    
}
