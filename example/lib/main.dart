import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control.dart';
import 'package:infineon_nfc_lock_control_example/pages/lock_controll_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformVersion();
  }

  Future<void> initPlatformVersion() async {
    String version;
    try {
      version =
          await InfineonNfcLockControl.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    debugPrint('Platform Version: $version');

    if (mounted) {
      setState(() {
        platformVersion = version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Lock Example',
      home: const LockControlPage(),
    );
  }
}
