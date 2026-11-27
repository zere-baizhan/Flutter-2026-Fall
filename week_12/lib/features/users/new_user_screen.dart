import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  static String? _validateUsername(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Required';
    if (s.contains(' ')) return 'No spaces';
    if (s.length < 3) return 'At least 3 characters';
    return null;
  }

  static String? _validateEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    return ok ? null : 'Not a valid email';
  }

  Future<void> _save() async {
    if (_saving) return; // a double tap sends one request
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final draft = User(
      id: 0, // the server assigns the real id
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
    );

    try {
      await context.read<UsersModel>().create(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        NoConnectionException() => 'No connection. Try again.',
        ServerException(:final status) => 'Server error ($status).',
        BadResponseException() => 'Could not read the server\'s answer.',
        NotFoundException() ||
        UnauthorizedException() => 'The server refused this request.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              validator: _validateUsername,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
