//
//  SaveValueHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

import CloudKit

class SaveValueHandler: CommandHandler {
    
    var COMMAND_NAME: String = "SAVE_VALUE"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        guard let containerId = arguments["containerId"] as? String, 
            let recordType = arguments["recordType"] as? String,
            let dataEntry = arguments["dataEntry"] as? [String: Any] else {
            result(FlutterError.init(code: "Error", message: "Cannot pass required parameters", details: nil))
            return
        }
        
        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let record = CKRecord(recordType: recordType)
        for (key, value) in dataEntry {
            switch value {
            case is String:
                record.setValue(value as? String, forKey: key)
            case is Int:
                record.setValue(value as? Int, forKey: key)
            case is Double:
                record.setValue(value as? Double, forKey: key)
            case is Bool:
                record.setValue(value as? Bool, forKey: key)
            case is [String]: // Here's where we handle the array of strings
                record.setValue(value as? [String], forKey: key)
            case is [Int]: // Here's where we handle the array of Ints
                record.setValue(value as? [Int], forKey: key)
            case is [Double]: // Here's where we handle the array of Doubles
                record.setValue(value as? [Double], forKey: key)
            case is [Bool]: // Here's where we handle the array of Bools
                record.setValue(value as? [Bool], forKey: key)
            default:
                result(FlutterError.init(code: "Error", message: "This data type is not supported", details: nil))
                return
            }
        }

        database.save(record) { (record, error) in
            if record != nil, error == nil {
                result(true)
            } else {
                result(false)
            }
        }
    }
}
