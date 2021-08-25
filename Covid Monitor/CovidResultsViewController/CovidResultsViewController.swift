//
//  CovidResultsViewController.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/23/21.
//

import UIKit
import Stellar
import HealthKit
import UIKit


class CovidResultsViewController: UIViewController {
    
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var reviewDataLabel: UILabel!
    @IBOutlet weak var animationContainerView: UIView!
    var animationView: CovidAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runAfter(seconds: 3, completionHandler: { [weak self] in
            self?.monitor()
        })
    }
    
    private func monitor() {
        
        let healthData = HealthDataExtractor()
        healthData.getSp02(completionHandler: { (finsihed) in
            healthData.getPulseData(completionHandler: { (finished2) in
                
                healthData.findCorrespondingDataPoints()
                
                let results = healthData.returnDataPoints()
                
                DispatchQueue.main.async {
                    
                    if results.isEmpty == false {
                        
                        let covidEvaluartor = CovidEvaluator()
                        covidEvaluartor.evaluateSp02Pulse(data: results)
                        
                        if covidEvaluartor.positveResultsPredicted() {
                            
                            let resultsData = covidEvaluartor.returnMoreInfo()
                            
                            var probability = resultsData["probability"] as? Double ?? 0.0
                            probability /= 0.01
                            let intProbability = Int(probability)
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd hh:mm a"
                            
                            self.resultsLabel.text = "Covid-19 has been detected with \(intProbability)% confidence on \(dateFormatter.string(from: (results.first?.0.startDate)!))"
                            self.resultsLabel.textColor = .red
                            self.resultsLabel.numberOfLines = 0
                            self.resultsLabel.adjustsFontSizeToFitWidth = true
                            
                        } else {
                            
                            self.resultsLabel.text = "Covid-19 has not been detected"
                        }
                        
                        /// Let user know last time a check was done
                        let dateFormatter = DateFormatter()
                        dateFormatter .dateFormat = "MM/dd hh:mm a"
                        
                        self.reviewDataLabel.text = "Last checked: \(dateFormatter.string(from: (results.first?.0.startDate)!))"
                    } else {
                        self.reviewDataLabel.text = ""
                        self.resultsLabel.text = "Not enough data yet, check back later"
                        self.resultsLabel.adjustsFontSizeToFitWidth = true
                    }
                }
            })
        })
    }
    

    override func viewDidLayoutSubviews() {
        if self.animationView == nil {
            self.animationView = CovidAnimationView(frame: CGRect(x: 0, y: 0, width: animationContainerView.frame.width, height: animationContainerView.frame.height))
            self.animationContainerView.addSubview(self.animationView!)
            self.animationView?.animateView()
        }
    }
}
