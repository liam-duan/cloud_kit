import CloudKit

class GetValueHandler: CommandHandler {
    
    var COMMAND_NAME: String = "GET_VALUE"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let key = arguments["key"] as? String, 
           let value = arguments["value"],
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {

            let database = CKContainer(identifier: containerId).privateCloudDatabase

            if let actualValue = value as? CVarArg {
                let predicate = NSPredicate(format: "\(key) == %@", argumentArray: [actualValue])
                let query = CKQuery(recordType: recordType, predicate: predicate)
        
                database.perform(query, inZoneWith: nil) { (records, error) in
                    if error == nil {
                        if let records = records, !records.isEmpty {
                            let foundRecord = records[0]
                            let recordMap = foundRecord.allKeys().reduce(into: [String: Any]()) { result, key in
                                result[key] = foundRecord[key]
                            }
                            result(recordMap)
                        } else {
                            result(FlutterError.init(code: "Error", message: "No records found", details: nil))
                        }
                    } else {
                        print("CloudKit error: \(error!.localizedDescription)")
                        result(FlutterError.init(code: "Error", message: "Error fetching records", details: nil))
                    }
                }
            } else {
                result(FlutterError.init(code: "Error", message: "Cannot cast value to a compatible type", details: nil))
            }
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass required parameters", details: nil))
        }
    }
}
