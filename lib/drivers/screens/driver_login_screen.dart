import 'package:flutter/material.dart';

import '../data/driver_api.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key, required this.api, required this.onSignedIn});
  final DriverApi api;
  final VoidCallback onSignedIn;

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      await widget.api.login(_email.text, _password.text);
      widget.onSignedIn();
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.delivery_dining, size: 64, color: Color(0xFF6D28D9)),
                  const SizedBox(height: 16),
                  const Text('Bokku Driver', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Sign in with your approved driver account.', textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    onSubmitted: (_) => _busy ? null : _submit()),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy ? const CircularProgressIndicator() : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
