import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';


class UsersCache {
  static const _fileName = 'users.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final e in raw) User.fromJson(e as Map<String, dynamic>)];
    } on FormatException {
      return null; // half-written or corrupted file
    } on TypeError {
      return null; // old format from a previous app version
    }
  }
}
