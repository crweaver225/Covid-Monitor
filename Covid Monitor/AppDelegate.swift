//
//  AppDelegate.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/23/21.
//

import UIKit
import BackgroundTasks
import HealthKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if (UserDefaults.standard.object(forKey: "FirstTime") as? Bool ?? true) != false {
            generateGlobalTabes()
            UserDefaults.standard.setValue(false, forKey: "FirstTime")
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let healthData = HealthDataExtractor()
        
        healthData.getSp02(completionHandler: { (finsihed) in
            
            healthData.getPulseData(completionHandler: { (finished2) in
                
                healthData.findCorrespondingDataPoints()
                
                let results = healthData.returnDataPoints()
                if results.isEmpty == false {
                    
                    let covidEvaluartor = CovidEvaluator()
                    covidEvaluartor.evaluateSp02Pulse(data: results)
                    
                    if covidEvaluartor.positveResultsPredicted()  {
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Warning"
                        content.body = "We may have detected signs that you are infected with Covid-19"
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 10, repeats: false)
                        
                        let newNotification = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
                        
                        let center = UNUserNotificationCenter.current()
                        center.add(newNotification, withCompletionHandler: { (error) in })
                        
                        completionHandler(.newData)
                    }
                } else { completionHandler(.noData) }
            })
        })
    }
        
        
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

