import 'package:flutter_test/flutter_test.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control_method_channel.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

void main() {
  final InfineonNfcLockControlPlatform initialPlatform = InfineonNfcLockControlPlatform.instance;

  group('InfineonNfcLockControl', () {
    test('$MethodChannelInfineonNfcLockControl is the default instance', () {
      expect(initialPlatform, isA<MethodChannelInfineonNfcLockControl>());
    });

    testWidgets('getPlatformVersion returns correct version', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      expect(await InfineonNfcLockControl.getPlatformVersion(), '42');
    });

    testWidgets('setupNewLock returns true on success', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      fakePlatform.mockSetupNewLockResult = true;

      final result = await InfineonNfcLockControl.setupNewLock(
        userName: 'testUser',
        supervisorKey: 'testSupervisorKey',
        newPassword: 'testNewPassword',
      );
      expect(result, isTrue);
    });

    testWidgets('changePassword returns true on success', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      fakePlatform.mockChangePasswordResult = true;

      final result = await InfineonNfcLockControl.changePassword(
        userName: 'testUser',
        supervisorKey: 'testSupervisorKey',
        newPassword: 'testNewPassword',
      );
      expect(result, isTrue);
    });

    testWidgets('lockPresent returns true on success', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      fakePlatform.mockLockPresentResult = true;

      final result = await InfineonNfcLockControl.lockPresent();
      expect(result, isTrue);
    });

    testWidgets('getLockId stream emits a value and completes', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      final lockIdValues = <String>[];
      final stream = InfineonNfcLockControl.getLockId();

      await for (final value in stream) {
        if (value is String) {
          lockIdValues.add(value);
        }
      }

      expect(lockIdValues, equals(['12345']));
    });

    testWidgets('unlockLockStream emits progress and completes successfully', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      final progressValues = <double>[];
      final stream = InfineonNfcLockControl.unlockLockStream(
        userName: 'testUser',
        password: 'testPassword',
      );

      await for (final progress in stream) {
        if (progress is double) {
          progressValues.add(progress);
        }
      }

      expect(progressValues, equals([0.1, 0.5, 1.0]));
    });

    testWidgets('lockLockStream emits progress and completes successfully', (WidgetTester tester) async {
      MockInfineonNfcLockControlPlatform fakePlatform = MockInfineonNfcLockControlPlatform();
      InfineonNfcLockControlPlatform.instance = fakePlatform;

      final progressValues = <double>[];
      final stream = InfineonNfcLockControl.lockLockStream(
        userName: 'testUser',
        password: 'testPassword',
      );

      await for (final progress in stream) {
        if (progress is double) {
          progressValues.add(progress);
        }
      }

      expect(progressValues, equals([0.1, 0.5, 1.0]));
    });
  });
}

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
  Stream<dynamic> lockLockStream({
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
  Stream<dynamic> unlockLockStream({
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