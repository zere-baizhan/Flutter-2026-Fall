import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required bool dark,
    String? city,
    String? avatarPath,
  }) : _dark = dark,
       _city = city,
       _avatarPath = avatarPath;

  final SharedPreferencesAsync _prefs;

  bool _dark;
  String? _city;
  String? _avatarPath;

  bool get dark => _dark;
  String? get city => _city;


  String? get avatarPath => _avatarPath;

  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners(); 
    await _prefs.setBool('darkMode', v); 
  }

  Future<void> setCity(String? c) async {
    _city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }
  Future<void> setAvatar(String fullPath, String fileName) async {
    _avatarPath = fullPath;
    notifyListeners();
    await _prefs.setString('avatarFile', fileName);
  }
}
