import 'package:flutter/material.dart';
import 'package:infineon_nfc_lock_control/infineon_nfc_lock_control.dart';

class LockControlPage extends StatefulWidget {
  const LockControlPage({super.key});

  @override
  State<LockControlPage> createState() => _LockControlPageState();
}

class _LockControlPageState extends State<LockControlPage> {
  // Controllers
  final _userNameController = TextEditingController();
  final _supervisorKeyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _changeNewPasswordController = TextEditingController();
  final _changeSupervisorKeyController = TextEditingController();
  final _changeUserNameController = TextEditingController();

  // State
  String _status = 'Idle';
  bool _lockPresent = false;
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

  void _showValidationErrors({required bool userName, bool supervisorKey = false}) {
    setState(() {
      _userNameError = userName && _userNameController.text.isEmpty;
      _supervisorKeyError = supervisorKey && _supervisorKeyController.text.isEmpty;
    });
  }

  Future<void> _checkLockPresence() async {
    try {
      final present = await InfineonNfcLockControl.lockPresent();
      setState(() {
        _lockPresent = present;
        _status = present ? 'Lock detected!' : 'No lock detected.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking lock presence: ${e.toString()}';
      });
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

    try {
      final success = await InfineonNfcLockControl.unlockLock(
        userName: _userNameController.text,
        password: _passwordController.text,
      );
      setState(() {
        _status = success ? 'Lock unlocked successfully!' : 'Failed to unlock lock.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error unlocking lock: ${e.toString()}';
      });
    }
  }

  Future<void> _lockLock() async {
    _showValidationErrors(userName: true);
    setState(() {
      _passwordError = _passwordController.text.isEmpty;
    });
    if (_userNameError || _passwordError) return;

    try {
      final success = await InfineonNfcLockControl.lockLock(
        userName: _userNameController.text,
        password: _passwordController.text,
      );
      setState(() {
        _status = success ? 'Lock locked successfully!' : 'Failed to lock lock.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error locking lock: ${e.toString()}';
      });
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
    if (_changeUserNameError || _changeSupervisorKeyError || _changeNewPasswordError) return;

    try {
      final success = await InfineonNfcLockControl.changePassword(
        userName: username,
        supervisorKey: supervisorKey,
        newPassword: _changeNewPasswordController.text,
      );
      setState(() {
        _status = success ? 'Password changed successfully!' : 'Failed to change password.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error changing password: ${e.toString()}';
      });
    }
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_lockPresent ? '🔓 Lock detected!' : '🔒 No lock detected'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _checkLockPresence, child: const Text('Check Lock Presence')),
          const Divider(height: 32),

          const Text('Setup New Lock', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildField(label: 'User Name', controller: _userNameController, showError: _userNameError),
          _buildField(label: 'Supervisor Key', controller: _supervisorKeyController, obscure: true, showError: _supervisorKeyError),
          _buildField(label: 'New Password', controller: _newPasswordController, obscure: true, showError: _newPasswordError),
          ElevatedButton(onPressed: _setupNewLock, child: const Text('Setup Lock')),

          const Divider(height: 32),
          const Text('Unlock Lock', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildField(label: 'Password', controller: _passwordController, obscure: true, showError: _passwordError),
          ElevatedButton(onPressed: _unlockLock, child: const Text('Unlock')),

          const Divider(height: 32),
          const Text('Lock Lock', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(onPressed: _lockLock, child: const Text('Lock')),

          const Divider(height: 32),
          const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildField(label: 'User Name', controller: _changeUserNameController, showError: _changeUserNameError),
          _buildField(label: 'Supervisor Key', controller: _changeSupervisorKeyController, obscure: true, showError: _changeSupervisorKeyError),
          _buildField(label: 'New Password', controller: _changeNewPasswordController, obscure: true, showError: _changeNewPasswordError),
          ElevatedButton(onPressed: _changePassword, child: const Text('Change Password')),

          const Divider(height: 32),
          Text('Status: $_status'),
        ]),
      ),
    );
  }
}
