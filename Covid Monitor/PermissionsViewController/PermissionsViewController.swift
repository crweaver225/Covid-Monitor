//
//  PermissionsViewController.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/23/21.
//

import UIKit
import Pastel
import HealthKit

class PermissionsViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var healthDataSwitch: UISwitch!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    @IBAction func continueButtonHit(_ sender: Any) {
        let covidResultsVC = CovidResultsViewController()
        covidResultsVC.modalPresentationStyle = .fullScreen
        self.present(covidResultsVC, animated: true, completion: nil)
    }
    
    @IBAction func healthDataSwitched(_ sender: Any) {
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if !success {
                UserDefaults.standard.setValue(false, forKey: "HealthPermissions")
            } else {
                UserDefaults.standard.setValue(true, forKey: "HealthPermissions")
            }
            self.displayNextButton()
        }
    }

    
    @IBAction func notificationsSwitched(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                UserDefaults.standard.setValue(true, forKey: "NotificationPermissions")
            } else {
                UserDefaults.standard.setValue(false, forKey: "NotificationPermissions")
                DispatchQueue.main.async {
                    self.notificationsSwitch.setOn(false, animated: true)
                    self.displayAlert(title: "Sorry", message: "You must turn on notifications to continue.")
                }
            }
            self.displayNextButton()
        }
    }
    
    private func displayAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { (action) in
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }))
        alertView.addAction(UIAlertAction(title: "I will do it later", style: .default, handler: { (action) in }))
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsSwitch.isOn = UserDefaults.standard.object(forKey: "NotificationPermissions") as? Bool ?? false
        healthDataSwitch.isOn = UserDefaults.standard.object(forKey: "HealthPermissions") as? Bool ?? false

        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
           pastelView.startPastelPoint = .bottomLeft
           pastelView.endPastelPoint = .topRight

           // Custom Duration
           pastelView.animationDuration = 3.0

           // Custom Color
           pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                                 UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                                 UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                                 UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                                 UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                                 UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                                 UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])

           pastelView.startAnimation()
           view.insertSubview(pastelView, at: 0)
        
        self.continueButton.layer.borderColor = UIColor.white.cgColor
        self.continueButton.layer.borderWidth = 0.5
        self.continueButton.layer.cornerRadius = 10
        
        displayNextButton()
    }


    func displayNextButton() {
        if ((UserDefaults.standard.object(forKey: "NotificationPermissions") as? Bool) ?? false) &&
            ((UserDefaults.standard.object(forKey: "HealthPermissions") as? Bool) ?? false) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 2.5, animations: {
                    self.continueButton.alpha = 1
                })
            }
        }
    }

}
