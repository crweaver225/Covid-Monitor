//
//  SData.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/24/21.
//

import Foundation

class SQL {
    
    var urlParams : URLParameters?
    
    init() {
        if let urlParamaters = returnURLParameters() {
            self.urlParams = urlParamaters
        }
    }


    func openDatabase(pathComponent: URL?) -> OpaquePointer {
        
        var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let DBURL : URL
        if let pathComponent = pathComponent {
            DBURL = pathComponent.appendingPathComponent("sqlite")
        } else {
            DBURL = paths[0].appendingPathComponent("sqlite")
        }

        var db: OpaquePointer? = nil
        if sqlite3_open(DBURL.absoluteString, &db) == SQLITE_OK {
            //do nothing
        } else {
            print("Unable to open database. ")
        }
        return db!
    }

    func syncDB(db : OpaquePointer, _ dbCommand: String) -> Bool {
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, dbCommand, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                return true
            } else {
                print("Could not updateDatabase")
                return false
            }
        } else {
            print("updateDatabase dbCommand could not be prepared")
            return false
        }
    }
    
    
    func closeDB(db : OpaquePointer) {
        sqlite3_close(db)
    }
    
    func prepareDB(db : OpaquePointer) {
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
    }
    
    func commitTransaction(db: OpaquePointer) {
        let updateStatement: OpaquePointer? = nil
        sqlite3_finalize(updateStatement)
        sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil)
    }

    func rollBackDatabase(db: OpaquePointer)  {
        let updateStatement: OpaquePointer? = nil
        sqlite3_finalize(updateStatement)
        sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
    }
    
    func updateDatabase(_ dbCommand: String, directory: URL?) -> Bool {
        var executed : Bool = false
        var updateStatement: OpaquePointer? = nil
        let db: OpaquePointer = openDatabase(pathComponent: directory)
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                executed = true
            } else {
                print("Could not updateDatabase")
            }
        } else {
            print("updateDatabase dbCommand could not be prepared")
            print(sqlite3_errmsg(db))
        }
        sqlite3_finalize(updateStatement)
        sqlite3_close(db)
        return executed
    }

    func dbValue(_ dbCommand: String) -> String {
        var getStatement: OpaquePointer? = nil
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        var value: String? = nil
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                let getResultCol = sqlite3_column_text(getStatement, 0)
                value = String(cString:getResultCol!)
            }
        } else {
            print("dbValue statement could not be prepared")
        }
        sqlite3_finalize(getStatement)
        sqlite3_close(db)
        if (value == nil) {
            value = ""
        }
        return value!
    }

    func nextID(_ tableName: String!) -> Int {
        var getStatement: OpaquePointer? = nil
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        let dbCommand = String(format: "select ID from %@ order by ID desc limit 1", tableName)
        var value: Int32? = 0
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                value = sqlite3_column_int(getStatement, 0)
            }
        } else {
            print("dbValue statement could not be prepared")
        }
        sqlite3_finalize(getStatement)
        sqlite3_close(db)
        var id: Int = 1
        if (value != nil) {
            id = Int(value!) + 1
        }
        return id
    }

    func dbInt(_ dbCommand: String!) -> Int
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        
        var value: Int32? = 0
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                value = sqlite3_column_int(getStatement, 0)
            }
        } else {
          //  print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        var int: Int = 1
        if (value != nil)
        {
            int = Int(value!)
        }
        return int
    }

    func getRows(_ dbCommand: String, directory: URL?) -> [[String : AnyObject]] {

        var outputArray = [[String : AnyObject]]()
        
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: directory)
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            
            while sqlite3_step(getStatement) == SQLITE_ROW {
                
                var rowDictionary: [String : AnyObject] = [:]
                
                let columnCount = sqlite3_column_count(getStatement)
                
                for i in 0..<columnCount {
                    
                    let type = sqlite3_column_type(getStatement, Int32(i))
                    
                    let val = sqlite3_column_text(getStatement, Int32(i))
                    
                    let val2 = sqlite3_column_int(getStatement, Int32(i))
               
                    let key = sqlite3_column_name(getStatement, Int32(i))
                    
                    if let val = val, let key = key {
                        
                        let valStr = String(cString: val)
                        
                        let row = String(cString: key)
                     
                        if type == 1 {
                            rowDictionary[row] = val2 as AnyObject?
                        } else {
                            rowDictionary[row] = valStr as AnyObject?
                        }
                    }
                }
                outputArray.append(rowDictionary)
            }
            
        } else {
            print("getRows statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        return outputArray
    }
}
