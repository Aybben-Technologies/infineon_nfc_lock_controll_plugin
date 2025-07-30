import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'infineon_nfc_lock_control_method_channel.dart'; // Ensure this import is correct

abstract class InfineonNfcLockControlPlatform extends PlatformInterface {
  InfineonNfcLockControlPlatform() : super(token: _token);

  static final Object _token = Object();

  static InfineonNfcLockControlPlatform _instance = MethodChannelInfineonNfcLockControl();

  static InfineonNfcLockControlPlatform get instance => _instance;

  static set instance(InfineonNfcLockControlPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  // Ensure these methods return Future<bool>
  Future<bool> setupNewLock({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    throw UnimplementedError('setupNewLock() has not been implemented.');
  }

  Future<bool> unlockLock({
    required String userName,
    required String password,
  }) {
    throw UnimplementedError('unlockLock() has not been implemented.');
  }

  Future<bool> changePassword({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    throw UnimplementedError('changePassword() has not been implemented.');
  }

  Future<bool> lockLock({
    required String userName,
    required String password,
  }) {
    throw UnimplementedError('lockLock() has not been implemented.');
  }

  Future<bool> lockPresent() {
    throw UnimplementedError('lockPresent() has not been implemented.');
  }
}