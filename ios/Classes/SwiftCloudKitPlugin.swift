import Flutter
import UIKit
import CloudKit

public class SwiftCloudKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "cloud_kit", binaryMessenger: registrar.messenger())
      let instance = SwiftCloudKitPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
  }

public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let callArguments: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
    
    switch call.method {
    case "GET_VALUE":
        GetValueHandler().handle(command: call.method, arguments: callArguments, result: result)
    case "SAVE_VALUE":
        SaveValueHandler().handle(command: call.method, arguments: callArguments, result: result)
    case "SAVE_VALUES":
        SaveValuesHandler().handle(command: call.method, arguments: callArguments, result: result)
    case "DELETE_VALUE":
        DeleteValueHandler().handle(command: call.method, arguments: callArguments, result: result)
    case "DELETE_ALL":
        DeleteAllHandler().handle(command: call.method, arguments: callArguments, result: result)
    case "GET_ACCOUNT_STATUS":
        GetAccountStatusHandler().handle(command: call.method, arguments: callArguments, result: result)
    default:
        result(FlutterMethodNotImplemented)
    }
}

}


