import CloudKit

class GetAllValuesHandler: CommandHandler {
    
    var COMMAND_NAME: String = "GET_ALL_VALUES"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {

            let database = CKContainer(identifier: containerId).privateCloudDatabase

            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: recordType, predicate: predicate)
        
            database.perform(query, inZoneWith: nil) { (records, error) in
                if error == nil {
                    if let records = records, !records.isEmpty {
                        var resultArray: [[String: Any]] = []
                        for record in records {
                            let recordMap = record.allKeys().reduce(into: [String: Any]()) { result, key in
                                result[key] = record[key]
                            }
                            resultArray.append(recordMap)
                        }
                        result(resultArray)
                    } else {
                        result(FlutterError.init(code: "Error", message: "No records found", details: nil))
                    }
                } else {
                    print("CloudKit error: \(error!.localizedDescription)")
                    result(FlutterError.init(code: "Error", message: "Error fetching records", details: nil))
                }
            }
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass required parameters", details: nil))
        }
    }
}
