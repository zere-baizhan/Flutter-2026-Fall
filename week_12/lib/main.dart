import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'dev_checks.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

const _runDevChecks = bool.fromEnvironment('DEV_CHECKS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const store = SecureStore();
  final api = ApiClient(Client(), store);
  final repo = UserRepository(api, UsersCache());

  if (_runDevChecks) {
    checkModel();
    await checkRepository(repo);
  }

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter'); // null = no filter
  final avatarPath = await _avatarPath(prefs);
  final token = await store.readToken(); // null = signed out

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city,
            avatarPath: avatarPath,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(create: (_) => UsersModel(repo)..load()),
      ],
      child: const App(),
    ),
  );
}

Future<String?> _avatarPath(SharedPreferencesAsync prefs) async {
  final name = await prefs.getString('avatarFile');
  if (name == null) return null;
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  return await file.exists() ? file.path : null;
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: context.watch<SettingsModel>().dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: context.watch<AuthModel>().signedIn
          ? const UsersScreen()
          : const LoginScreen(),
    );
  }
}
