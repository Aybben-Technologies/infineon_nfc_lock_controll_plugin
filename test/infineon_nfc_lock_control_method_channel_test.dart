import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelInfineonNfcLockControl platform = MethodChannelInfineonNfcLockControl();
  const MethodChannel channel = MethodChannel('infineon_nfc_lock_control');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
