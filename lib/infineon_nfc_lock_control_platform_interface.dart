import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Stream<double> lockLockStream({
    required String userName,
    required String password,
  }) {
    throw UnimplementedError('lockLockStream() has not been implemented.');
  }

  Stream<double> unlockLockStream({
    required String userName,
    required String password,
  }) {
    throw UnimplementedError('unlockLockStream() has not been implemented.');
  }

  Future<bool> setupNewLock({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    throw UnimplementedError('setupNewLock() has not been implemented.');
  }

  Future<bool> changePassword({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    throw UnimplementedError('changePassword() has not been implemented.');
  }

  Future<bool> lockPresent() {
    throw UnimplementedError('lockPresent() has not been implemented.');
  }
}