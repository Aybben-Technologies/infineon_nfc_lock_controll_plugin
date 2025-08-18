import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'infineon_nfc_lock_control_platform_interface.dart';

class MethodChannelInfineonNfcLockControl
    extends InfineonNfcLockControlPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('infineon_nfc_lock_control');

  @visibleForTesting
  final eventChannel = const EventChannel('infineon_nfc_lock_control_stream');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<bool> setupNewLock({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) async {
    return await methodChannel.invokeMethod<bool>('setupNewLock', {
          'userName': userName,
          'supervisorKey': supervisorKey,
          'newPassword': newPassword,
        }) ??
        false;
  }

  @override
  Future<bool> changePassword({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) async {
    return await methodChannel.invokeMethod<bool>('changePassword', {
          'userName': userName,
          'supervisorKey': supervisorKey,
          'newPassword': newPassword,
        }) ??
        false;
  }

  @override
  Future<bool> lockPresent() async {
    return await methodChannel.invokeMethod<bool>('lockPresent') ?? false;
  }

  @override
  Stream<dynamic> unlockLockStream({
    required String userName,
    required String password,
  }) {
    return eventChannel.receiveBroadcastStream({
      'method': 'unlockLock',
      'userName': userName,
      'password': password,
    });
  }

  @override
  Stream<dynamic> lockLockStream({
    required String userName,
    required String password,
  }) {
    return eventChannel.receiveBroadcastStream({
      'method': 'lockLock',
      'userName': userName,
      'password': password,
    });
  }
}
