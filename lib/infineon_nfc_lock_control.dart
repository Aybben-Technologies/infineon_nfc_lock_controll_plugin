import 'infineon_nfc_lock_control_platform_interface.dart';

class InfineonNfcLockControl {
  static Future<String?> getPlatformVersion() {
    return InfineonNfcLockControlPlatform.instance.getPlatformVersion();
  }

  static Stream<double> lockLockStream({
    required String userName,
    required String password,
  }) {
    return InfineonNfcLockControlPlatform.instance.lockLockStream(
      userName: userName,
      password: password,
    );
  }

  static Stream<double> unlockLockStream({
    required String userName,
    required String password,
  }) {
    return InfineonNfcLockControlPlatform.instance.unlockLockStream(
      userName: userName,
      password: password,
    );
  }

  static Future<bool> setupNewLock({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    return InfineonNfcLockControlPlatform.instance.setupNewLock(
        userName: userName,
        supervisorKey: supervisorKey,
        newPassword: newPassword);
  }

  static Future<bool> changePassword({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    return InfineonNfcLockControlPlatform.instance.changePassword(
        userName: userName,
        supervisorKey: supervisorKey,
        newPassword: newPassword);
  }

  static Future<bool> lockPresent() {
    return InfineonNfcLockControlPlatform.instance.lockPresent();
  }
}