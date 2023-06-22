import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'types/CloudKitAccountStatus.dart';
export 'types/CloudKitAccountStatus.dart';

/// A Wrapper for CloudKit
class CloudKit {
  static const MethodChannel _channel = const MethodChannel('cloud_kit');

  String _containerId = '';
  String _recordType = '';
  CloudKit(String containerIdentifier, {String recordType = "StorageItem"}) {
    _containerId = containerIdentifier;
    _recordType = recordType;
  }

  /// Save a new entry to CloudKit using a key and value.
  /// The key need to be unique.
  /// Returns a boolean [bool] with true if the save was successfully.
  Future<bool> saveMultiple(List<Map<String, dynamic>> values) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (values.isEmpty) {
      return false;
    }

    bool status = await _channel.invokeMethod('SAVE_VALUES', {
          "recordType": _recordType,
          "dataEntries": values,
          "containerId": _containerId
        }) ??
        false;

    return status;
  }

  Future<bool> save(Map<String, dynamic> value) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (value.isEmpty) {
      return false;
    }

    bool status = await _channel.invokeMethod('SAVE_VALUE', {
          "recordType": _recordType,
          "dataEntry": value,
          "containerId": _containerId
        }) ??
        false;

    return status;
  }

  /// Loads a value from CloudKit by key.
  /// Returns a string [string] with the saved value.
  /// This can be null if the key was not found.
  Future<Map<String, dynamic>?> get(String key, dynamic value) async {
    if (!Platform.isIOS) {
      return null;
    }

    if (key.isEmpty || value == null) {
      return null;
    }
    print(_recordType);
    Map<String, dynamic> record =
        Map<String, dynamic>.from(await _channel.invokeMethod('GET_VALUE', {
      "recordType": _recordType,
      "key": key,
      "value": value,
      "containerId": _containerId,
    }) as Map);

    return record;
  }

  /// Delete a entry from CloudKit using the key.
  Future<bool> delete(String key) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (key.length == 0) {
      return false;
    }

    bool success = await _channel.invokeMethod('DELETE_VALUE', {
          "key": key,
          "containerId": _containerId,
        }) ??
        false;

    return success;
  }

  /// Deletes the entire user database.
  Future<bool> clearDatabase() async {
    if (!Platform.isIOS) {
      return false;
    }

    bool success = await _channel
            .invokeMethod('DELETE_ALL', {"containerId": _containerId}) ??
        false;

    return success;
  }

  /// Gets the iCloud account status
  /// This is useful to check first if the user is logged in
  /// and then trying to save data to the users iCloud
  Future<CloudKitAccountStatus> getAccountStatus() async {
    if (!Platform.isIOS) {
      return CloudKitAccountStatus.notSupported;
    }

    int accountStatus = await _channel
        .invokeMethod('GET_ACCOUNT_STATUS', {"containerId": _containerId});

    return CloudKitAccountStatus.values[accountStatus];
  }
}
