//
//  GlobalFunctions.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/24/21.
//

import Foundation


import Foundation


func returnDateFromString(stringDate : String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM-dd-yyyy hh:mm a"
    return dateFormatter.date(from: stringDate) ?? Date()
}
func convertWebDateToPhoneDate(stringDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM, dd yyyy HH:mm:ss"
    return dateFormatter.date(from: stringDate) ?? Date()
}
func currentTimeString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM, dd yyyy HH:mm:ss"
    return dateFormatter.string(from: Date())
}
func currentTimeStringMillisecond() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
    return dateFormatter.string(from: Date())
}
func syncItemsTimeString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM, dd YYYY hh:mm a"
    return dateFormatter.string(from: Date())
}
func lastUpdateTime() -> String {
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM, dd YYYY hh:mm a"
    let date = Date()
    let dateString = dateFormatter.string(from: date)
    return dateString
}
func returnPresentableTime(oldTime: String) -> String {
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM, dd yyyy HH:mm:ss"
    if let dateFromString = dateFormatter.date(from: oldTime) {
        dateFormatter.dateFormat = "MMMM dd h:mm a"
        return dateFormatter.string(from: dateFromString)
    }
    return ""
}
func displayLastUpdateTime() -> String? {
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM-dd-yyyy hh:mm a"
    let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? String ?? ""
    if let dateFromString = dateFormatter.date(from: lastUpdateDate) {
        dateFormatter.dateFormat = "MMMM dd h:mm a"
        return dateFormatter.string(from: dateFromString)
    }
    return nil
}

struct URLParameters {
    var exhibitorKey : String
    var showID : String
    var clientID : String
    var deviceKey : String
    var userID : String
    var applicationKey : String
    var server : String
}

func returnURLParameters() -> URLParameters? {
     if let exhibitorKey = UserDefaults.standard.object(forKey: "exhibitorKey") as? String, let showID = UserDefaults.standard.object(forKey: "showKey") as? String, let clientID = UserDefaults.standard.object(forKey: "clientKey") as? String, let deviceKey = UserDefaults.standard.object(forKey: "deviceKey") as? String, let userID = UserDefaults.standard.object(forKey: "userKey") as? String, let applicationKey = UserDefaults.standard.object(forKey: "applicationKey") as? String, let server = UserDefaults.standard.object(forKey: "server") as? String  {
        
        let urlParameters = URLParameters(exhibitorKey: exhibitorKey, showID: showID, clientID: clientID, deviceKey: deviceKey, userID: userID, applicationKey: applicationKey, server: server)
        return urlParameters
    }
    return nil
}

func runAfter(seconds: Int, completionHandler : @escaping () ->Void) {
    let timeInterval : DispatchTimeInterval = DispatchTimeInterval.seconds(seconds)
    let when = DispatchTime.now() + timeInterval
    DispatchQueue.main.asyncAfter(deadline: when) {
        completionHandler()
    }
}

func generateGlobalTabes() {
    let sql = SQL()
    let testTable = "CREATE TABLE test_table (key_id TEXT PRIMARY KEY,create_date TEXT, sp02 FLOAT, pulse FLOAT, result INTEGER, probability FLOAT)"
    sql.updateDatabase(testTable , directory: nil)
}

func generateTables() {
    
    if let _ = returnURLParameters() {
        
        let sql = SQL()
        
        let leadsMaster = "CREATE TABLE leads_master (key_id TEXT PRIMARY KEY , create_date TEXT, client_id TEXT, badge_id TEXT, device_key TEXT, link_key TEXT, parent_key TEXT, scanner_id TEXT, show_id TEXT, title TEXT, first_name TEXT, last_name TEXT, address1 TEXT, Address2 TEXT, city TEXT, company_name TEXT, country TEXT, email TEXT, phone TEXT, state TEXT, zip_code TEXT, updated TEXT, vstamp TEXT, custom_flag1 INTEGER, custom_flag2 INTEGER, modified INTEGER, type INTEGER, sub_type INTEGER, active INTEGER, vsync1 INTEGER, vsync2 INTEGER )"
        
        sql.updateDatabase(leadsMaster, directory: FilePathManager.returnCurrentFilePath())
        
        let leadsDetail = "CREATE TABLE leads_detail (key_id TEXT PRIMARY KEY , client_id TEXT, create_date TEXT, description TEXT, link_key TEXT, parent_key TEXT, show_id TEXT, user_id TEXT, updated TEXT, vstamp TEXT, custom_flag1 INTEGER, custom_flag2 INTEGER, modified INTEGER, status INTEGER, type INTEGER, sub_type INTEGER, active INTEGER, vsync1 INTEGER, vsync2 INTEGER, title TEXT )"
        
        sql.updateDatabase(leadsDetail, directory: FilePathManager.returnCurrentFilePath())
        
        let invMast = "CREATE TABLE inv_mast (key_id TEXT PRIMARY KEY , client_id TEXT, description TEXT, link_key TEXT, parent_key TEXT, create_date TEXT, custom_text5 TEXT, show_id TEXT, user_id TEXT, title TEXT, updated TEXT, booth_no TEXT, custom_link1 TEXT, vstamp TEXT, display_order INTEGER, type INTEGER, net_code INTEGER, sub_type INTEGER, active INTEGER, answer_sort INTEGER, question_type INTEGER, site_sync INTEGER, version_flag1 INTEGER, upload_height INTEGER, upload_width INTEGER, mx_map_engine INTEGER, map_version INTEGER, modified INTEGER, archive INTEGER, status INTEGER )"
        
        sql.updateDatabase(invMast, directory: FilePathManager.returnCurrentFilePath())
        
        let invDetail = "CREATE TABLE inv_detail (key_id TEXT PRIMARY KEY , client_id TEXT, description TEXT, link_key TEXT, parent_key TEXT, create_date TEXT, show_id TEXT, user_id TEXT, title TEXT, custom_text6 TEXT, custom_link1 TEXT, vstamp TEXT, updated TEXT, ribbon_code TEXT, display_order INTEGER, type INTEGER, currency INTEGER, net_code INTEGER, sub_type INTEGER, active INTEGER, archive INTEGER, status INTEGER )"
        
        sql.updateDatabase(invDetail, directory: FilePathManager.returnCurrentFilePath())
        
        let syncItems = "CREATE TABLE sync_items(key_id TEXT PRIMARY KEY, client_id TEXT, show_id TEXT, exhibitor_id TEXT, create_date TEXT , sql_statement TEXT)"
        
        sql.updateDatabase(syncItems, directory: FilePathManager.returnCurrentFilePath())
    }
}
