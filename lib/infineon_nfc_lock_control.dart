import 'infineon_nfc_lock_control_platform_interface.dart';

class InfineonNfcLockControl {
  static Future<String?> getPlatformVersion() {
    return InfineonNfcLockControlPlatform.instance.getPlatformVersion();
  }

  static Future<bool> setupNewLock({ // Already correct
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    return InfineonNfcLockControlPlatform.instance
        .setupNewLock(userName: userName, supervisorKey: supervisorKey, newPassword: newPassword);
  }

  static Future<bool> unlockLock({ // Already correct
    required String userName,
    required String password,
  }) {
    return InfineonNfcLockControlPlatform.instance
        .unlockLock(userName: userName, password: password);
  }

  static Future<bool> changePassword({ // Already correct
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) {
    return InfineonNfcLockControlPlatform.instance
        .changePassword(userName: userName, supervisorKey: supervisorKey, newPassword: newPassword);
  }

  static Future<bool> lockLock({ // Already correct
    required String userName,
    required String password,
  }) {
    return InfineonNfcLockControlPlatform.instance
        .lockLock(userName: userName, password: password);
  }

  static Future<bool> lockPresent() {
    return InfineonNfcLockControlPlatform.instance.lockPresent();
  }
}