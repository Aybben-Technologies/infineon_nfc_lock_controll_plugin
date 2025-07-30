import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'infineon_nfc_lock_control_platform_interface.dart';

class MethodChannelInfineonNfcLockControl extends InfineonNfcLockControlPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('infineon_nfc_lock_control');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<bool> setupNewLock({ // Return type is Future<bool>
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) async {
    // Ensure invokeMethod is typed to <bool>
    return await methodChannel.invokeMethod<bool>('setupNewLock', {
      'userName': userName,
      'supervisorKey': supervisorKey,
      'newPassword': newPassword,
    }) ?? false; // Provide a default value for null safety
  }

  @override
  Future<bool> unlockLock({ // Return type is Future<bool>
    required String userName,
    required String password,
  }) async {
    // Ensure invokeMethod is typed to <bool>
    return await methodChannel.invokeMethod<bool>('unlockLock', {
      'userName': userName,
      'password': password,
    }) ?? false;
  }

  @override
  Future<bool> changePassword({ // Return type is Future<bool>
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) async {
    // Ensure invokeMethod is typed to <bool>
    return await methodChannel.invokeMethod<bool>('changePassword', {
      'userName': userName,
      'supervisorKey': supervisorKey,
      'newPassword': newPassword,
    }) ?? false;
  }

  @override
  Future<bool> lockLock({ // Return type is Future<bool>
    required String userName,
    required String password,
  }) async {
    // Ensure invokeMethod is typed to <bool>
    return await methodChannel.invokeMethod<bool>('lockLock', {
      'userName': userName,
      'password': password,
    }) ?? false;
  }

  @override
  Future<bool> lockPresent() async {
    return await methodChannel.invokeMethod<bool>('lockPresent') ?? false;
  }
}