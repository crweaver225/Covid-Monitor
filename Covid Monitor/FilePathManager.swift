//
//  FilePathManager.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/24/21.
//

import Foundation


import Foundation
import UIKit

class FilePathManager {
    
    private static var fileManager = FileManager.default
    
    class func returnOtherFilePath(client: String, show: String, exhibitor: String) -> URL? {
        if let filePath = createAndReturnFilePath(clientID: client, showKey: show, exhibitorKey: exhibitor) {
            return filePath
        }
        return nil
    }
    
    static func createAndReturnFilePath(clientID: String, showKey: String, exhibitorKey: String) -> URL? {
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("\(exhibitorKey)/\(clientID)/\(showKey)")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    return filePath
                } catch {
                    NSLog("Couldn't create document directory")
                }
            } else {
                return filePath
            }
        }
        return nil
    }
    
    class func doesFileExist(path: String) -> Bool {
        if fileManager.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }

    class func returnCurrentFilePath() -> URL? {
        if let params = returnURLParameters() {
            if let filePath = createAndReturnFilePath(clientID: params.clientID, showKey: params.showID, exhibitorKey: params.exhibitorKey) {
                return filePath
            }
        } else {
            return nil
        }
        return nil
    }

}
