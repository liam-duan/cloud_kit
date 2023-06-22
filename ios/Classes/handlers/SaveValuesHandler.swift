//
//  SaveValuesHandler.swift
//  cloud_kit
//
//

import CloudKit

class SaveValuesHandler: CommandHandler {
    
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
            let dataEntries = arguments["dataEntries"] as? [[String: Any]] else {
            result(FlutterError.init(code: "Error", message: "Cannot pass required parameters", details: nil))
            return
        }
        
        let database = CKContainer(identifier: containerId).privateCloudDatabase
        var recordsToSave = [CKRecord]()

        for dataEntry in dataEntries {
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
                case is [String]:
                    record.setValue(value as? [String], forKey: key)
                case is [Int]:
                    record.setValue(value as? [Int], forKey: key)
                case is [Double]:
                    record.setValue(value as? [Double], forKey: key)
                case is [Bool]:
                    record.setValue(value as? [Bool], forKey: key)
                default:
                    result(FlutterError.init(code: "Error", message: "This data type is not supported", details: nil))
                    return
                }
            }
            recordsToSave.append(record)
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                result(FlutterError.init(code: "Error", message: error.localizedDescription, details: nil))
            } else {
                result(true)
            }
        }
        
        database.add(operation)
    }
}
