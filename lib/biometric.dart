import 'package:flutter/material.dart';
import 'package:pwacam/services/passkey_service.dart';
import 'services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  String _message = '';
  bool _passkeySupported = false;

  @override
  void initState() {
    super.initState();
    _checkPasskeySupport();
  }

  Future<void> _checkPasskeySupport() async {
    try {
      final supported = await PasskeyService.isSupported();
      setState(() {
        _passkeySupported = supported;
      });
      _showMessage('Passkey support: $supported');
    } catch (e) {
      _showMessage('Error checking passkey support: $e');
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _testApiRegistration() async {
    try {
      final username = _usernameController.text;
      final displayName = _displayNameController.text;

      if (username.isEmpty || displayName.isEmpty) {
        _showMessage('Please enter username and display name');
        return;
      }

      _showMessage('Starting API registration...');

      final options = await AuthService.startRegistration(username, displayName);
      _showMessage('Registration options received');

      await Future.delayed(const Duration(seconds: 1));

      final verification = await AuthService.finishRegistration(username, {'id': 'test-credential', 'type': 'public-key'});

      _showMessage('API Registration: ${verification['success']} - ${verification['message']}');
    } catch (e) {
      _showMessage('API Error: $e');
    }
  }

  Future<void> _testApiAuthentication() async {
    try {
      final username = _usernameController.text;

      if (username.isEmpty) {
        _showMessage('Please enter username');
        return;
      }

      _showMessage('Starting API authentication...');

      final options = await AuthService.startAuthentication(username);
      _showMessage('Authentication options received');

      await Future.delayed(const Duration(seconds: 1));

      final verification = await AuthService.finishAuthentication(username, {'id': 'test-credential', 'type': 'public-key'});

      _showMessage('API Authentication: ${verification['success']} - ${verification['message']}');
    } catch (e) {
      _showMessage('API Error: $e');
    }
  }

  Future<void> _testPasskeyRegistration() async {
    try {
      final username = _usernameController.text;
      final displayName = _displayNameController.text;

      if (username.isEmpty || displayName.isEmpty) {
        _showMessage('Please enter username and display name');
        return;
      }

      _showMessage('Starting Passkey registration...');
      await PasskeyService.registerWithPasskey(username, displayName);
      _showMessage('Passkey registration completed successfully!');
    } catch (e) {
      _showMessage('Passkey Error: $e');
    }
  }

  Future<void> _testPasskeyAuthentication() async {
    try {
      final username = _usernameController.text;

      if (username.isEmpty) {
        _showMessage('Please enter username');
        return;
      }

      _showMessage('Starting Passkey authentication...');
      final success = await PasskeyService.authenticateWithPasskey(username);
      _showMessage('Passkey authentication: $success');
    } catch (e) {
      _showMessage('Passkey Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Auth Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Passkey Supported: $_passkeySupported', style: TextStyle(color: _passkeySupported ? Colors.green : Colors.red)),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('API Tests:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: _testApiRegistration, child: const Text('API Register')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(onPressed: _testApiAuthentication, child: const Text('API Auth')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Passkey Tests:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: _passkeySupported ? _testPasskeyRegistration : null, child: const Text('Passkey Register')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(onPressed: _passkeySupported ? _testPasskeyAuthentication : null, child: const Text('Passkey Auth')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(child: Text(_message, style: const TextStyle(fontSize: 16))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
