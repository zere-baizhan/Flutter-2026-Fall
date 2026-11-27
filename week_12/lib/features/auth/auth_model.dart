import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

/// thrown the fake login the password is too short
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? token}) : _signedIn = token != null;

  final SecureStore _store;
  bool _signedIn;

  bool get signedIn => _signedIn;

  /// fake backend
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) throw const InvalidCredentialsException();

    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token); // disk first
    _signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _signedIn = false;
    notifyListeners();
  }
}
