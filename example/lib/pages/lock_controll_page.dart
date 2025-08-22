import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control.dart';

class LockControlPage extends StatefulWidget {
  const LockControlPage({super.key});

  @override
  State<LockControlPage> createState() => _LockControlPageState();
}

class _LockControlPageState extends State<LockControlPage> {
  final _userNameController = TextEditingController();
  final _supervisorKeyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _changeNewPasswordController = TextEditingController();
  final _changeSupervisorKeyController = TextEditingController();
  final _changeUserNameController = TextEditingController();

  String _status = '0%';
  double _progress = 0.0;
  bool _lockPresent = false;
  String _lockId = 'Not detected';
  bool _userNameError = false;
  bool _supervisorKeyError = false;
  bool _changeSupervisorKeyError = false;
  bool _changeUserNameError = false;
  bool _passwordError = false;
  bool _newPasswordError = false;
  bool _changeNewPasswordError = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _supervisorKeyController.dispose();
    _newPasswordController.dispose();
    _passwordController.dispose();
    _changeNewPasswordController.dispose();
    _changeSupervisorKeyController.dispose();
    _changeUserNameController.dispose();
    super.dispose();
  }

  void _showValidationErrors({
    required bool userName,
    bool supervisorKey = false,
  }) {
    setState(() {
      _userNameError = userName && _userNameController.text.isEmpty;
      _supervisorKeyError =
          supervisorKey && _supervisorKeyController.text.isEmpty;
    });
  }

  Future<void> _getLockId() async {
    try {
      setState(() {
        _status = 'Getting lock ID...';
      });
      await for (final event in InfineonNfcLockControl.getLockId()) {
        if (event is String) {
          setState(() {
            _lockId = event;
            _status = 'Lock ID received!';
          });
        }
      }
    } catch (e) {
      _animateErrorProgress(currentProgress: _progress);
      setState(() {
        _status = 'Error getting lock ID: ${e.toString()}';
      });
    }
  }

  Future<void> _checkLockPresence() async {
    try {
      final present = await InfineonNfcLockControl.lockPresent();
      setState(() {
        _lockPresent = present;
        _status = present ? 'Lock detected!' : 'No lock detected.';
      });
    } catch (e) {
      _animateErrorProgress(currentProgress: _progress);
    }
  }

  Future<void> _setupNewLock() async {
    _showValidationErrors(userName: true, supervisorKey: true);
    setState(() {
      _newPasswordError = _newPasswordController.text.isEmpty;
    });
    if (_userNameError || _supervisorKeyError || _newPasswordError) return;

    try {
      final success = await InfineonNfcLockControl.setupNewLock(
        userName: _userNameController.text,
        supervisorKey: _supervisorKeyController.text,
        newPassword: _newPasswordController.text,
      );
      setState(() {
        _status = success ? 'Lock setup successful!' : 'Lock setup failed.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error setting up lock: ${e.toString()}';
      });
    }
  }

  Future<void> _unlockLock() async {
    _showValidationErrors(userName: true);
    setState(() {
      _passwordError = _passwordController.text.isEmpty;
    });
    if (_userNameError || _passwordError) return;

    bool success = false;
    try {
      setState(() {
        _status = 'Unlocking lock...';
        _progress = 0.0;
      });

      await for (var event in InfineonNfcLockControl.unlockLockStream(
        userName: _userNameController.text,
        password: _passwordController.text,
      )) {
        if (event is String) {
          setState(() {
            _lockId = event;
          });
        } else if (event is double) {
          setState(() {
            _progress = min(event / 100, 1.0);
            _status = 'Unlocking: ${min(event, 100.0).toStringAsFixed(0)}%';
          });
        }
      }

      success = true;
    } catch (e) {
      _animateErrorProgress(currentProgress: _progress);
    } finally {
      if (success) {
        setState(() {
          _status = 'Lock unlocked successfully!';
          _progress = 0.0;
        });
      } else {
        // Animate progress to 0% and reset status to '0%'
        _animateErrorProgress(currentProgress: _progress);
      }
    }
  }

  Future<void> _lockLock() async {
    _showValidationErrors(userName: true);
    setState(() {
      _passwordError = _passwordController.text.isEmpty;
    });
    if (_userNameError || _passwordError) return;

    bool success = false;
    try {
      setState(() {
        _status = 'Locking lock...';
        _progress = 0.0;
      });

      await for (var event in InfineonNfcLockControl.lockLockStream(
        userName: _userNameController.text,
        password: _passwordController.text,
      )) {
        if (event is String) {
          setState(() {
            _lockId = event;
          });
        } else if (event is double) {
          setState(() {
            _progress = min(event / 100, 1.0);
            _status = 'Locking: ${min(event, 100.0).toStringAsFixed(0)}%';
          });
        }
      }

      success = true;
    } catch (e) {
      _animateErrorProgress(currentProgress: _progress);
    } finally {
      if (success) {
        setState(() {
          _status = 'Lock locked successfully!';
          _progress = 0.0;
        });
      } else {
        // Animate progress to 0% and reset status to '0%'
        _animateErrorProgress(currentProgress: _progress);
      }
    }
  }

  Future<void> _changePassword() async {
    final username = _changeUserNameController.text;
    final supervisorKey = _changeSupervisorKeyController.text;
    setState(() {
      _changeUserNameError = username.isEmpty;
      _changeSupervisorKeyError = supervisorKey.isEmpty;
      _changeNewPasswordError = _changeNewPasswordController.text.isEmpty;
    });
    if (_changeUserNameError ||
        _changeSupervisorKeyError ||
        _changeNewPasswordError) {
      return;
    }

    try {
      final success = await InfineonNfcLockControl.changePassword(
        userName: username,
        supervisorKey: supervisorKey,
        newPassword: _changeNewPasswordController.text,
      );
      setState(() {
        _status = success
            ? 'Password changed successfully!'
            : 'Failed to change password.';
      });
    } catch (e) {
      _animateErrorProgress(currentProgress: _progress);
    }
  }

  // Reset status to '0%' on error
  void _animateErrorProgress({required double currentProgress}) {
    double tempProgress = currentProgress;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (tempProgress <= 0.0) {
        timer.cancel();
        setState(() {
          _progress = 0.0;
          _status = '0%';
        });
      } else {
        setState(() {
          tempProgress -= 0.05;
          _progress = max(tempProgress, 0.0);
        });
      }
    });
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    bool showError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$label is required',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Lock Plugin Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status'),

            if (_progress > 0.0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(value: _progress),
              ),
            Text(_lockPresent ? '🔓 Lock detected!' : '🔒 No lock detected'),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Lock ID: $_lockId'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _getLockId,
              child: const Text('Get Lock ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _checkLockPresence,
              child: const Text('Check Lock Presence'),
            ),
            const Divider(height: 32),

            const Text(
              'Setup New Lock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildField(
              label: 'User Name',
              controller: _userNameController,
              showError: _userNameError,
            ),
            _buildField(
              label: 'Supervisor Key',
              controller: _supervisorKeyController,
              obscure: true,
              showError: _supervisorKeyError,
            ),
            _buildField(
              label: 'New Password',
              controller: _newPasswordController,
              obscure: true,
              showError: _newPasswordError,
            ),
            ElevatedButton(
              onPressed: _setupNewLock,
              child: const Text('Setup Lock'),
            ),

            const Divider(height: 32),
            const Text(
              'Unlock Lock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildField(
              label: 'Password',
              controller: _passwordController,
              obscure: true,
              showError: _passwordError,
            ),
            ElevatedButton(onPressed: _unlockLock, child: const Text('Unlock')),

            const Divider(height: 32),
            const Text(
              'Lock Lock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(onPressed: _lockLock, child: const Text('Lock')),

            const Divider(height: 32),
            const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildField(
              label: 'User Name',
              controller: _changeUserNameController,
              showError: _changeUserNameError,
            ),
            _buildField(
              label: 'Supervisor Key',
              controller: _changeSupervisorKeyController,
              obscure: true,
              showError: _changeSupervisorKeyError,
            ),
            _buildField(
              label: 'New Password',
              controller: _changeNewPasswordController,
              obscure: true,
              showError: _changeNewPasswordError,
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Change Password'),
            ),

            const Divider(height: 32),
          ],
        ),
      ),
    );
  }
}