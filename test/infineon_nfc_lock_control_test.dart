import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInfineonNfcLockControlPlatform
    with MockPlatformInterfaceMixin
    implements InfineonNfcLockControlPlatform {
  String? mockPlatformVersionResult = '42';
  bool mockSetupNewLockResult = false;
  bool mockChangePasswordResult = false;
  bool mockLockPresentResult = false;

  @override
  Future<String?> getPlatformVersion() => Future.value(mockPlatformVersionResult);

  @override
  Stream<dynamic> getLockId() async* {
    yield '12345';
  }

  @override
  Future<bool> setupNewLock({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) => Future.value(mockSetupNewLockResult);

  @override
  Future<bool> changePassword({
    required String userName,
    required String supervisorKey,
    required String newPassword,
  }) => Future.value(mockChangePasswordResult);

  @override
  Future<bool> lockPresent() => Future.value(mockLockPresentResult);

  @override
  Stream<double> lockLockStream({
    required String userName,
    required String password,
  }) async* {
    yield 0.1;
    await Future.delayed(const Duration(milliseconds: 10));
    yield 0.5;
    await Future.delayed(const Duration(milliseconds: 10));
    yield 1.0;
  }

  @override
  Stream<double> unlockLockStream({
    required String userName,
    required String password,
  }) async* {
    yield 0.1;
    await Future.delayed(const Duration(milliseconds: 10));
    yield 0.5;
    await Future.delayed(const Duration(milliseconds: 10));
    yield 1.0;
  }
}